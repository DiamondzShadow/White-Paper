# 11. Protocol Integrations — 0x, Uniswap, Chainlink

The ecosystem leans on three external protocols as foundational infrastructure rather than interchangeable dependencies. This section documents *exactly* where and how each is used, the specific API versions we rely on, the failure modes we have already hit, and the guardrails we added after each one.

---

## 11.1 0x — Swap Aggregation & Token Vetting

0x is the ecosystem's default swap venue for any pair without a deep on-chain pool. We use **0x Swap API v2** (the v1 API is deprecated) and the **AllowanceHolder** flow rather than Permit2 — AllowanceHolder is simpler for contract-initiated swaps from our V15 Swapper and ShadowzDex adapters, and doesn't require the Permit2 signature dance that is painful to coordinate from a Safe.

### Where 0x is wired

1. **V15 Swapper V3** (legacy V11, retained for DBV basket rebalancing) — fires 0x quotes every 4 hours, rebalances any basket token more than 5% off its target weight.
2. **ShadowzDex 0x venue adapter** — default fallback when no direct pool exists for a user intent. The adapter calls 0x Swap API v2 via AllowanceHolder and verifies the received `amountOut ≥ minOut` on-chain.
3. **Token Tester** — before the DAO can add a new token to a basket, the tester runs seven 0x quote probes ($1 / $10 / $50 / $100 / $250 / $500 / $1,000) through 0x and emits one of `APPROVED / CAUTION / LOW_LIQUIDITY / REJECTED`. A `REJECTED` result blocks the governance proposal at the UI level.
4. **CrabbyMultiZap** — single-asset entry to the 3-asset Crabby pool uses a 0x quote to split the incoming deposit across WETH / PGOLD / wSOL.

### Router whitelist

The only 0x router contract any of our contracts will call is `AllowanceHolder` at `0x0000000000001ff3684f28c67538d4d072c22734`. Every Swapper / Adapter holds this address as an immutable constant, not a `setSwapRouter()` parameter — that was a deliberate choice after an audit call flagged `setSwapRouter()` as an attack surface if the admin key were ever compromised.

### Failure modes we've hit

- **Insufficient liquidity on small notionals** — the Token Tester probing at $1 caught several tokens that pass a $1,000 quote but fail a $10 one. Don't trust a single-size quote for any token candidate.
- **`INSUFFICIENT_ASSET_LIQUIDITY` errors** on fallback — the venue adapter now catches this and surfaces it to the attestor, which picks a secondary venue (Sushi V2, Uni V3).
- **Slippage surprise on micro-caps** — the V11-era Pendle experiment shipped four distinct bugs including a struct-layout mismatch against the 0x response shape; all Pendle routes were abandoned and `USDC-native` adapters are now the rule.

### Why 0x is a good partner here

0x gives us (a) permissionless integration (no approval needed to list a token), (b) a single RFQ surface that pulls liquidity from most AMMs including Uniswap V2/V3, Sushi V2, and Curve, and (c) a predictable quote shape we can verify on-chain. We re-check `minOut` after every 0x call because we trust the protocol, not the API response in transit.

---

## 11.2 Uniswap — Pool Liquidity, SDM/USDC Pair, LP Financialization

Uniswap is where SDM price formation happens and where the ecosystem's external LPs plug in. We use Uniswap V3 directly for SDM price, and both Uniswap V2 and V3 (plus Sushi V2/V3, which use the same factory pattern) as input to the ShadowzDex `/pools` surface.

### 11.2.1 SDM/USDC Uniswap V3 Pool

The canonical SDM price oracle is the SDM/USDC Uniswap V3 pool on Arbitrum:

| Parameter | Value |
|-----------|-------|
| Pool address | `0x25a7f80d191086B77cEB5Bb368C3e71F875Bb4AE` |
| Fee tier | 1% |
| Initial price range | $0.01 – $0.10 |
| Pair | SDM (`0x602b869e…`) / USDC |

The 1% fee tier matches SDM's volatility profile and long-tail-token liquidity depth. The `SDMLPZapV2` contract (`0x6e5286F9…`) lets users zap a single asset into the pool: 50% of the incoming USDC is swapped to SDM via a **TWAP oracle check** (not spot) to prevent sandwich attacks, the remaining 50% is sent straight to treasury, and the balanced pair is deposited as a concentrated-range V3 position.

`SDMLPFarm` (`0x0CFa723e…`) emits 1,000,000 SDM over 90 days to LP depositors, and `VestedLPFarm` (`0x31eEaE67…`) provides a 250,000 SDM vesting track for long-duration LPs.

### 11.2.2 Uniswap V2/V3 paste-box on /pools

The ShadowzDex `/pools` surface lets a user paste any Uniswap V2, Uniswap V3, Sushi V2, or Sushi V3 pool address. A factory-whitelisted detector identifies the pool class (we check the pool's claimed factory against an ecosystem-approved list) and mounts the correct deposit card:

- **V2 paste** → `LPDepositCard` → `addLiquidity` with equal-value split
- **V3 paste** → `LPDepositCardV3` → full-range mint (wider-than-concentrated for beginners; no tick picker needed)

Factory whitelisting is how we deter spoofed-pool attacks: a malicious pool can claim the Uniswap factory but fails the factory-address check. 9 unit tests cover the detect-and-mount paths.

### 11.2.3 LPFeeGateway — the cleanest fee hook in the system

Every V2 or V3 LP deposit routed through the `/pools` paste-box passes through the **LPFeeGateway** at `0xbb99…8044B` on Arb. The gateway:

1. Pulls **0.03%** of the user's deposited assets into the Arbitrum treasury Safe,
2. Forwards the remaining 99.97% to the Uniswap / Sushi router,
3. Emits a `FeeCollected` event the attestor indexes into the marketplace banner.

This is the single cleanest fee hook in the ecosystem: every LP deposit, regardless of venue (V2 or V3, Uniswap or Sushi), regardless of pair, surfaces through one contract. See §9 for how the LPFeeGateway revenue feeds SDM treasury.

### 11.2.4 LP positions as financial NFTs

Uniswap V3 positions are ERC-721 NFTs. The ecosystem's `ArbPositionWrapper` (§6.5.1) can wrap a Uni V3 position as a `BasketReceipt`-class NFT, at which point it becomes listable on the EcosystemMarketplace and collateralizable in LendingPool v1.4. This is how a user's Uniswap LP position inherits the full ShadowVault financial-NFT toolkit without any code change on the Uniswap side.

### 11.2.5 Uniswap V4 Hooks — deferred

We evaluated Uniswap V4 hooks as a venue for the ShadowzDex intent router. The work is deferred; the current CCIP-based cross-chain path already proved a $1 USDC round-trip, so there is no near-term reason to rewrite against V4 hooks. The Uniswap Hooks MCP is connected for future reference.

---

## 11.3 Chainlink — CCIP Mesh, Price Feeds, Valuation Guards

Chainlink is the ecosystem's trust-minimized cross-chain and oracle backbone. We use **three Chainlink products**: CCIP (cross-chain), Data Feeds (price oracles), and (indirectly) the feed staleness semantics that gate every valuation call.

### 11.3.1 CCIP — Cross-Chain Messaging & Token Transfer

Chainlink CCIP is the canonical cross-chain path for SDM, for ShadowzDex intents, and for NFT value pushes.

**SDM multichain via CCIP** — SDM is CCIP-native on four chains:

| Chain | SDM address | CCIP pool |
|-------|-------------|-----------|
| Arbitrum (home) | `0x602b869e…3394` | canonical |
| Polygon | `0xDd5C…` | CCIP pool |
| Base | `0x64F5a84b…02f0` | `0x8cecbac8…a502` |
| HyperEVM | via white-glove pool | staged |

The three-way CCIP mesh Arb ↔ Poly ↔ Base was verified end-to-end on 2026-04-20. SDM is *extended* to new chains via existing CCIP pools — we do not redeploy SDM "as a new token" anywhere (that was an early mistake corrected in the SDM CCIP-native design doc).

**zSDM multichain** — the upgradable zSDM wrapper is live on Arb + Polygon + Base + HyperEVM at the same CREATE3 address (`0xfc8D5874…d00470`), with the Arb Lockbox at `0x188b887B…2275`. Path B (direct LayerZero OFT + future Hyperlane / CCIP adapters) was chosen because the Lucid org whitelist was not granted; each bridge adapter is wired directly onto zSDM.

**NFT value push over CCIP** — the `ccip-value-push` keeper (§6.6) signs periodic `NFTValuer.setVaultMirror(tokenId, usd)` updates for wrapped Polygon → Arb positions.

**ShadowzDex intent settlement** — cross-chain user intents settle over the same CCIP mesh. The 2026-04-21 $1 Arb ↔ Base round-trip was settled end-to-end on CCIP with no bridge outside Chainlink's in the loop.

### 11.3.2 Data Feeds — Price Oracles

Chainlink price feeds underpin every USD-denominated valuation in the ecosystem:

- **Wrapper ratios** — wSDM (SDM + WBTC, 50/50), gSDM (SDM + XAUT, 50/50), sSDM (SDM + USDC, 20/80) all enforce their backing ratio using Chainlink feeds with configurable **staleness thresholds**. A feed older than the threshold reverts the mint/redeem — we do not synthesize prices.
- **V15 adapters** — any adapter that needs to convert a non-USDC yield token back to USDC on harvest uses a Chainlink feed to compute the expected amount and reverts on slippage beyond the configured tolerance. The Polygon V15 port uses the verified Chainlink feeds listed in `project_polygon_v15_port.md`.
- **NFTValuer** — see §6.3. The valuer pulls live vault state and multiplies by the appropriate Chainlink-fed prices; a stale feed is a hard revert, not a soft fallback, because a stale valuation is the highest-risk input to NFT-backed lending.
- **ShadowzDex intent `oracle` field** — each 11-field intent names the Chainlink feed to enforce `minOut` against. The router checks feed staleness at dispatch time, independent of what the attestor claimed.

### 11.3.3 Chainlink Automation (considered)

We considered Chainlink Automation for the keeper fleet but opted for **self-hosted PM2 keepers on GCP VMs** for cost reasons at current scale. The Automation migration path remains open: each keeper (`sweep-v2-arb`, `sweep-v2-poly`, `ccip-value-push`, `lz-value-push`) is idempotent and can be moved to Automation without a contract change.

### 11.3.4 Why Chainlink

Three reasons: (a) CCIP is the only cross-chain protocol with a permissioned token-pool topology that the Diamondz Safes can administer directly without a third-party bridge signer, (b) Data Feeds have staleness semantics we can enforce on-chain, which the cheaper oracle alternatives do not offer, and (c) a single operational relationship (feeds + CCIP from the same vendor) simplifies incident response.

---

## 11.4 Uniblock & GeckoTerminal — Market Data

Not a smart-contract dependency, but listed here for completeness. The `/pools`, `/earn`, and `/marketplace` banners pull market data from:

- **Uniblock REST API** — primary. Auth via `Bearer` header. The real REST paths (not the doc filenames) are at the Uniblock reference noted in our internal docs. Gotcha: `walletAddress` vs `walletAddr` — we always use `walletAddress`. Coingecko mapping has a coverage cliff: requests for non-listed tokens fail silently, not with a 4xx.
- **GeckoTerminal** — fallback when Uniblock returns no match. Used for long-tail tokens that the CG mapping doesn't cover.

Both data paths are routed through `attestor.diamondz.one` server-side so API keys never ship to the browser. This was the right pattern even for read-only keys — we document this separately in our internal "match key warnings to blast radius" feedback, but operationally the rule is always: **no keys in the browser**.
