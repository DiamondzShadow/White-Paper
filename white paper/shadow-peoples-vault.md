# 3. ShadowVault V15

ShadowVault V15 is the production deposit-and-earn layer of the Diamondz Shadow ecosystem. Each vault is a position-based, USDC-denominated strategy that mints a live-value financial NFT on deposit and routes yield into a single, audited adapter. V15 is live on **Arbitrum One**, **Polygon**, and **HyperEVM**, with a Solana mirror staged on devnet.

The design goal of V15 was to kill every class of bug that plagued earlier revisions: no swap-step adapters, no shared-registry posId collisions, no inflation exploits, no orphaned yield shares on 100% utilization, no empty-revert `requestWithdraw`. Every adapter exposes `rescueToken`, every vault calls the adapter directly (not through a router), and every NFT position syncs its `tokenId` to the vault's `posId`.

---

## 3.1 V15 Architecture

ShadowVault V15 is a three-contract per-chain stack plus shared infrastructure:

| Layer | Contract | Role |
|-------|----------|------|
| Vault | `ShadowVaultV15` | Deposit / withdraw / position state, fees, tier multipliers |
| Adapter | One per strategy | Holds strategy-side funds, harvests yield, enforces USDC-in / USDC-out |
| Position NFT | `YieldReceipt` / `BasketReceipt` | ERC-721 with live portfolio value, trades transfer the vault position |
| Oracle | `NFTValuer v2` | Reads live vault state, mirrors across chains via CCIP + LayerZero |
| Revenue | `Seeder V2` | Routes fees to SDM buyback (50%) + Arb Safe treasury (50%) |

Admin is a **per-chain Gnosis Safe** (addresses in §13). The vault has no `Ownable` surface — it uses OpenZeppelin `AccessControl` with the Safe holding `DEFAULT_ADMIN_ROLE`.

---

## 3.2 Live Vaults

### Arbitrum One (LIVE)

| Pool | Label | Adapter strategy | Status |
|------|-------|------------------|--------|
| A | Morpho | Morpho USDC vault supply | LIVE |
| B | GMX | GMX V2 GM market deposit (Synthetics) | LIVE |
| C | Aave | Aave V3 USDC supply (no loops, no E-Mode) | LIVE |
| D | Fluid | Fluid lending USDC | LIVE |

### Polygon (LIVE)

| Pool | Label | Adapter strategy | Status |
|------|-------|------------------|--------|
| A | Aave | Aave V3 USDC supply | LIVE |
| B | Gains | Gains Network gUSDC (epoch-aware) | LIVE |
| C | Aave | Aave V3 secondary allocation | LIVE |
| D | C4C | C4C V4 strategy vault (`0x8Fd0195…EBE9`) | LIVE |

### HyperEVM (LIVE)

| Pool | Label | Adapter strategy | Status |
|------|-------|------------------|--------|
| E | HyperSkin | HLPAdapterHC — Hyperliquid HLP vault (HyperCore bridge) | LIVE |
| F | ShadowPass | Trader-EOA-directed sub-strategy (governed-keeper) | LIVE |

All 9 live vaults have `whitelistEnabled = false` (open access) and accept USDC directly via `vault.deposit(amount, tier)` — the IntentRouter → V15PoolAdapter legacy path was retired because the adapter carried an accounting bug.

---

## 3.3 Lock Tiers & Share Multipliers

Tiers are the primary incentive for long-duration capital. Breaking a lock forfeits the multiplier — a cost that dominates the fee differential.

| Tier | Lock | Share multiplier |
|------|------|------------------|
| FLEX | none | 1.0× |
| 30D | 30 days | 1.2× |
| 90D | 90 days | 1.5× |
| 180D | 180 days | 2.0× |
| 365D | 365 days | 3.0× |

---

## 3.4 Fee Structure (V15, updated 2026-04-19)

| Fee | Rate | Collected on | Destination |
|-----|------|--------------|-------------|
| Entry fee (FLEX only, planned) | 3% | Deposit, tier-0 only | Arb Safe (treasury) |
| Early exit | 3% | Withdraw before lock expires | Seeder V2 |
| On-time / FLEX withdraw | 12% ➝ 1.2%* | Withdraw at or after lock | Seeder V2 |
| Protocol yield fee | 3% | Keeper-harvested yield | Seeder V2 |

\* The 12-bps / 3-bps / 3-bps schedule (often written as **"12/3/3"**) is the V15 canonical rate: **1.2%** on-time / FLEX withdraw, **0.3%** yield fee, **0.3%** early-exit discount when the user holds a DAW NFT. All nine vaults on Arbitrum, Polygon, and HyperEVM Pool E were bumped to this schedule on 2026-04-19.

100% of every fee eventually reaches the **Seeder V2** revenue router, which splits 50/50 into SDM buyback + LP seeding and the Arbitrum treasury Safe. See §9 *Unified Fee Flywheel* for the cross-protocol map.

---

## 3.5 Yield Engine — USDC-Native Only

V15 enforces an explicit rule: **adapters must deposit and return USDC.** No adapter may internally swap to or from a non-USDC asset, because every prior revision that did so shipped a bug (Pendle `SYInvalidTokenOut`, Gamma/ICHI token residue on withdraw, Balancer swap step). This constraint eliminates slippage risk on the exit path and makes every vault mechanically identical from the user's perspective.

Adapter contract rules:

- USDC in, USDC out — no intermediate asset held on the adapter across calls
- `maxRedeem` / `maxDeposit` checked before calling — returns 0 gracefully on epoch lock or cap hit
- `rescueToken(token, to, amount)` admin function on every adapter (non-negotiable)
- Namespaced per-item storage keyed by `msg.sender` for shared registries (avoids the BonusAccumulator posId collision class of bug)

---

## 3.6 Financial NFTs — Live-Value Positions

Every deposit mints a position NFT. V15 uses a three-NFT architecture:

| NFT | Role | Live value source |
|-----|------|-------------------|
| `YieldReceipt` | Pool A–D / Pool F positions (single-strategy) | Vault posId → `NFTValuer` |
| `BasketReceipt` | Diamond Basket Vault shares (multi-asset) | DBV share price × balance |
| `ShadowPass` | Pool E HyperSkin access + trait layer | HLP equity + Safe-gated traits |

The NFT is the position: selling on OpenSea transfers the underlying vault deposit. The ERC-721 `tokenId` is synced to the vault `posId` via `syncNextTokenId()`; the vault never calls `nft.mint()` outside `deposit()`. This is the bedrock rule — violating it breaks tradability and was the root cause of early sync failures.

The NFTs are **cross-chain bridgeable**:

- **Polygon → Arb**: `PolygonNFTLocker` (`0xd67ACb…65aD`) locks, CCIP emits, `ArbPositionWrapper` (`0x43e91f…4BA0`) mints a wrapped position registered in the Arb `DiggerRegistry` and valued through `NFTValuer.VAULT_MIRROR`.
- **HyperEVM → Arb**: `HyperPositionLocker` (`0xFC8f588b…7381`) locks via LayerZero, `HyperPositionWrapper` (`0x4228b8E9…fd68`, verified) mints on Arb. DVN config was read-back-verified on both libraries on both chains. `ShadowPassValuer` (`0x27980Da1…C702`) prices wrapped ShadowPass NFTs.

The `lz-value-push` and `ccip-value-push` keepers (PM2-managed) push the latest USD value onto the wrapper so the NFT's live value updates on whichever chain it currently lives on.

See §6 *Financial NFTs & Lending* for how these NFTs are listed for sale, borrowed against, and auto-repaid from accrued yield.

---

## 3.7 DAO vs Admin Security Separation

V15 preserves V11's on-chain role split:

**DAO-controllable (via vSDM Governor + Timelock):** fee rates, basket/yield split, revenue split, yield fee rate, tier multipliers, whitelist enable flag.

**Safe-only (`DEFAULT_ADMIN_ROLE`):** pause/unpause, whitelist set, adapter/swapper/seeder/valuer address changes, `rescueToken`, role grants/revokes.

Even a hostile vSDM majority can only move economic parameters — it cannot drain funds, switch adapters, or pause the vault. That separation is the same one documented in §5.4.

---

## 3.8 Token Tester

Before the DAO can add a new token to any basket (or before an adapter can list a new strategy), the candidate must pass the **Token Tester**: seven quote probes through the 0x Swap API v2 at $1 / $10 / $50 / $100 / $250 / $500 / $1,000 notional. The tool emits one of four verdicts — `APPROVED`, `CAUTION`, `LOW_LIQUIDITY`, `REJECTED` — and the result is attached to the governance proposal. This is the gate that killed the weETH LST experiment (swap complexity) and the full Pendle basket series (four distinct bugs, abandoned). See §11 for the 0x integration details.
