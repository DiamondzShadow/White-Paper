# 16. ShadowzDex Launchpad & Position-NFT Presales

The Launchpad is the ecosystem's token- and NFT-issuance venue on Arbitrum. It runs two parallel models from one registry: a **permissionless generic factory** (ProRata or Dutch fair-launch sales) and **bespoke Position-NFT presales** where every commit mints a live-valued ERC-721 that earns yield while the sale is open, lists on the marketplace, and borrows on the lending pool. It is live at the [dex.diamondz.one](https://dex.diamondz.one) `/launchpad` surface.

---

## 16.1 Architecture

A monolithic factory exceeded the 24 KB contract limit (it was ~33 KB), so the design splits into a thin **registry** plus cloneable implementations.

| Contract | Address (Arbitrum) | Role |
|----------|--------------------|------|
| LaunchpadRegistry | `0x74a821383939CEe120B5d7b6700947a6582F8F20` | Canonical fee config + sale registry; source of truth for `/launchpad` listing |
| LaunchpadFactoryV2 | `0x35C23FcF6b34273884b9Dd3419e3DB2530107459` | Permissionless factory (clones ProRata / Dutch) |
| ProRata impl | `0xA49Fc7ae63abd376099E07D3250451B83d1CD513` | Pro-rata sale template |
| Dutch impl | `0x5824165Ea389BC002e43b16D5C7A79a8D605ba2b` | Dutch-auction sale template |
| DiggerRegistry | `0x090275f1ddae9e37C28D495AD9f9044723D787c9` | Collateral-eligibility registry (shared with lending) |

**Dynamic platform fee.** Sales carry a platform fee that *floats with marketing delivered* — a base rate (2–3%) that can rise to a 10% cap as CrabbyTV reach and Crabs-in-a-Barrel media are delivered against the sale. A sale only appears on `/launchpad` once its creation fee is satisfied: **$450 USDC to treasury, waived for creators holding ≥ 100,000 SDM**. The sale itself runs fully even if unpaid — only its public listing is gated.

---

## 16.2 Position-NFT Presales

Bespoke presales (`TemplatePresale` / `TemplatePresaleV2`) mint one ERC-721 **Position NFT** per commit. Each NFT is a financial primitive on day one: its USD value is read live by a `PresaleValuer`, idle USDC is parked in a yield sink (§16.3), and the NFT is both marketplace-listable and borrowable. Two are live:

| Sale | Address | Token | Renderer v2 | PresaleValuer | Raise band | Offered |
|------|---------|-------|-------------|---------------|------------|---------|
| **CrabbyTV Presale (v4)** | `0x4b2aa1B3c109c3f26BFd57B046dFCdE5e2d97709` | CRAB | `0xEDCfC6FDAF2D673d60E17256EF2920F929f65D49` | `0x5786354626E4D7853a2ef0671c366aaFD1e13439` | $50k–$500k | 100M CRAB |
| **Shadow Reborn (SDM)** | `0xcAf1A1fBf073E2A109BD794CCa35D8C85e01bc69` | SDM | `0x8Ab05fb2eBABF1Db7e9695752B26843d890D0E50` | `0xD44F3597be846DBdB6707c88C3Ed2f693B1388FF` | $25k–$250k | 50M SDM |

Both grant a **10% weighted-USD holder bonus** (for V15 holders), carry a 0.5% royalty (waived for allowlisted holders), and settle to the Arbitrum treasury Safe `0x18b2b2ce7d05Bfe0883Ff874ba0C536A89D07363`. The Position NFT's on-chain renderer encodes tier (Bronze/Silver/Gold), committed USD, and founder status, and — for Shadow Reborn — injects a deep-link to the streaming watch surface (§17).

---

## 16.3 IYieldSink — Presale Deposits Earn While Pending

Idle presale USDC is not dead capital. `IYieldSink` is a **trust-minimized, vault-bound** sink: a sink is bound to exactly one presale at deploy and can *only* return funds to that vault — no owner, no upgrade, no path to move funds elsewhere.

| Implementation | Backing | Status |
|----------------|---------|--------|
| **AaveV3YieldSink** (primary) | Aave V3 USDC (aUSDC 1:1, monotonic) | **LIVE on both presales** |
| **MorphoYieldSink** (backup) | MetaMorpho ERC-4626 USDC vault | Built; failover for Aave pause/cap |

Aave is primary because aUSDC grows monotonically and `totalAssets()` always covers principal + accrued yield. Morpho is the failover; its ERC-4626 shares are value-tracking (not 1:1) and carry residual bad-debt risk, so it is held in reserve. Yield accrues live while sales are open:

| Sink contract | Address (Arbitrum) |
|---------------|--------------------|
| Aave Pool | `0x794a61358D6845594F94dc1DB02A252b5b4814aD` |
| aUSDC | `0x724dc807b04555b71ed48a6896b6F41593b8C637` |

---

## 16.4 Borrow Against a Presale Position

Both live presales are registered `IN_HOUSE` in `DiggerRegistry`, making their Position NFTs lending collateral. The `/borrow` page scans the `BORROWABLE_PRESALES` set (CrabbyTV Presale + Shadow Reborn) and surfaces a holder's positions.

| Parameter | Value |
|-----------|-------|
| Lending pool (Arb) | `0xc2f02Dff81d019d10d23d9A29bC774830D54290E` |
| NFT valuer (Arb) | `0x83b946C721a0B5f5871DC91F884b364D1410f131` |
| Max LTV | 27% |
| APR | 8% |

Flow: connect → view presale Position NFTs → borrow up to `usdValue × 27%` in USDC → the NFT is escrowed → repay any time to release. This ties the presale into the broader Financial-NFT lending stack (§6): a presale commit is simultaneously a yield-bearing position, a tradable NFT, and a credit line.

---

## 16.5 Durable Sale Registration — Temporal + Worker

A sale that is *paid but not listed* is the launchpad's worst failure mode. Registration is therefore made durable by two cooperating pieces:

- **`launchpad-registrar`** (Cloudflare Worker, live at `launchpad-registrar.crabby.workers.dev/register`) — the fast inline path. A creator deploys the sale from their own wallet and POSTs the address; the Worker (holding `SALE_CREATOR_ROLE`) validates the fee config against canonical values and the creation-fee gate, then calls `registerSale()`. The attempt is written to KV *before* any on-chain work, so a crash mid-registration leaves a recoverable record. Returns `402` if the creation fee is unsatisfied, idempotent on re-submit.
- **`launch-registrar-workflow`** (Temporal Cloud, namespace `temporal.diamondz.one`, task queue `launch-registrar`) — the durable backstop. It polls the Worker's `/pending` endpoint and finishes any stuck registration via a retry loop (exponential backoff, ~hours, up to 100 attempts). Transient failures (RPC down, tx unindexed) retry; permanent business errors throw `ApplicationFailure.nonRetryable` and fail fast. A companion `registerCollectionWorkflow` lists launched collections as marketplace sell-only (no collateral) via a narrow `CURATOR_ROLE` proxy.

The combination guarantees that once a creator has paid and deployed, the sale *will* become listed, surviving Worker outages and RPC flakiness.
