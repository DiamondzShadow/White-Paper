# 8. CrabbyTV Platform

CrabbyTV is the ecosystem's live-streaming platform with virtual gift/tipping, co-host multi-video grid, and FAST channel distribution (Roku, Fire TV, Apple TV). The AI co-host (Beyond Presence avatar + Claude + 11Labs) can join livestreams with a per-minute USDC pre-deposit model routed to the Arbitrum Safe.

> The Crabby stack has since grown into a full **creator and entertainment layer** — Crabby Social v2, Crabs in a Barrel, the launchpad, and streaming NFTs. The complete treatment, including the canonical CRABBY v2 token and current addresses, is in **§15 (Crabby Creator Ecosystem)**, **§16 (Launchpad)**, and **§17 (Streaming NFTs)**. This section retains the original CrabbyTV MVP context.

---

## 8.1 CrabbyTV MVP Contract

`CrabbyTVMVP.sol` provides on-chain creator milestone validation and progression:

- Creator registration and oracle milestone submission
- Progression model: Milestone Units → Creator Credits (10:1) → Reputation Badges (100:1) → Wavz Score
- Auto-verification at ≥95% confidence; manual verification below threshold
- Optional token rewards via mintable reward token

---

## 8.2 CrabbyTV DeFi Infrastructure

| Contract | Address | Purpose |
|----------|---------|---------|
| **CRABBY (v2, canonical)** | `0x05387b385be4D5038C755e7efA3D742f1b5B2bEB` | Platform utility token (3B supply, UUPS proxy) |
| CrabbyToken (v1, deprecated) | `0x33e3DdD8d9952DE9D8D005529F844c8d9c14f3Af` | Superseded — do not wire |
| CrabbyPoolV1 | `0x12470c8ce5e5CbBaF4367b65ee42Ee2E8Db86812` | WETH/PGOLD/wSOL 3-asset pool |
| CrabbyLPFarm | `0xf5ca0303211f18E5a896e6D1478865b5F94cFa27` | Stake CRABLP, earn CRABBY |
| CrabbyMultiZap | `0xCf5c4A9C90c198E3bAf04c4fe682608D40409Bb9` | Single-asset entry via 0x quote |

---

# 9. Unified Fee Flywheel — All Protocol Fees → SDM Treasury

Every protocol in the ecosystem — ShadowVault V15, ShadowzDex, the EcosystemMarketplace, LendingPool v1.4, the DiamondzChain Bridge, the LP paste-box — routes its fees into a single on-chain flow. The end state is always the same: 50% executes an SDM buyback and seeds SDM/USDC liquidity, 50% lands in the Arbitrum treasury Safe (`0x6052C6559eD5e5CbE74Ac0D42205Ad4A1CFBEd43`). SDM value tracks ecosystem activity directly, and every incremental user — a V15 depositor, a DEX trader, an LP, a marketplace buyer, a borrower — makes the buyback deeper.

---

## 9.1 Fee Source Map

| Source | Rate | Where collected | On-chain route |
|--------|------|-----------------|----------------|
| **ShadowVault V15 — early exit** | 0.3% | `ShadowVaultV15.withdraw` pre-lock | Seeder V2 → 50/50 split |
| **ShadowVault V15 — on-time / FLEX** | 1.2% | `ShadowVaultV15.withdraw` on or after lock | Seeder V2 → 50/50 split |
| **ShadowVault V15 — protocol yield** | 5% | Keeper-harvested adapter yield | Seeder V2 → 50/50 split |
| **ShadowVault V15 — FLEX entry (planned)** | 3% | `deposit(tier=FLEX)` | Arb Safe (direct) |
| **ShadowzDex — LPFeeGateway** | 0.03% | `LPFeeGateway` on any V2/V3 LP deposit | Arb Safe (direct) |
| **ShadowzDex — intent fee (pending FeeVault)** | 5–20 bps | `IntentRouter` dispatch, SDM-tiered | FeeVault → 50/50 split |
| **EcosystemMarketplace — royalty** | 2.5% | `RoyaltyRouter` on secondary sale | Arb Safe (direct) |
| **EcosystemMarketplace — listing bond** | 0.1 USDC flat | `DiggerRegistry.register` | Arb Safe (direct) |
| **LendingPool v1.4 — borrow interest split** | 10% of interest | `LendingPool.accrue` | Arb Safe (direct) |
| **LendingPool v1.4 — liquidation penalty** | Variable | `AaveV3Sink` skim | SweepController → Arb Safe |
| **DiamondzChain Bridge — small tx** | $0.42 / $0.30 flat | `BridgeLock.lock` on Arb | BridgeFeeDAO → 50% treasury / 26% validators / 14% zwSDM pool / 10% SDM pool |
| **DiamondzChain Bridge — large tx** | 0.30% | `BridgeLock.lock` ≥ $100 | BridgeFeeDAO (same split) |
| **DiamondzChain Bridge — burn-back** | 0.60% | zwToken `bridgeBurn` | BridgeFeeDAO (same split) |
| **AI co-host (CrabbyTV)** | per-minute | USDC pre-deposit | Arb Safe (direct) |
| **Launchpad — platform fee** | 2–3% base, 10% cap | `LaunchpadRegistry` per sale, floats with marketing | Arb Safe (direct) |
| **Launchpad — creation fee** | $450 USDC (waived ≥100k SDM) | `launchpad-registrar` gate | Arb Safe (direct) |
| **Presale — royalty** | 0.5% (waived for allowlist) | `TemplatePresale` secondary | Arb Safe (direct) |
| **Crabby Social — post-trade split** | 10 bps | `CrabbyPostMarketV2` | Treasury 2 bps / creator + repost + community |
| **Crabby Social — community LP fees** | 30% of V3 swap fees | `CommunityLPVault.collectFees` | Arb Safe (30%) / creator (70%) |
| **ShadowzPerps — HL builder fee** | 0.3 bps/trade | HL builder code | swept → Arb Safe |
| **ShadowzPerps — AI chat** | $0.10/request | x402 → Base Safe | bridged → Arb Safe |
| **DEX-agent — limit fill / DCA** | 5 bps / $0.10 | prepaid credits | Arb Safe (direct) |

---

## 9.2 Seeder V2 — The Canonical Revenue Router

`Seeder V2` (`0x23e48B14177b6288b5c961d3000CD2666bdc2550` on Arb) is the contract every V15 vault and the future ShadowzDex `FeeVault` point at. On each fee deposit it:

1. Splits the incoming USDC 50/50
2. Routes **50%** to the DODO DPP (DBV/USDC) pool `0x781dfce2518b9840e8f0165333bdff3170ef1f9c`, purchasing SDM and seeding the SDM/USDC Uniswap V3 LP via `SDMLPZapV2`
3. Routes the other **50%** to the Arbitrum treasury Safe

The buyback half is the flywheel: every fee dollar deepens SDM/USDC liquidity, and deeper liquidity supports tighter price bands for the next wave of buyers.

---

## 9.3 Fees Routed Direct to Safe (Bypassing Seeder)

Some fees land directly in the Safe without the Seeder split. These are fees whose volatility or accounting complexity makes a `swap-then-split` step unsafe:

- **LPFeeGateway 0.03%** — fires inside the same call as the Uniswap/Sushi `addLiquidity`; routing it through the Seeder would double the gas on every LP deposit.
- **Marketplace royalty** — the NFT's sale currency can be USDC or any ERC-20 the seller listed against; the royalty is paid in the listing currency, and converting to USDC is deferred to a keeper batch.
- **Lending interest split** — booked as a balance on the pool, swept to the Safe periodically.
- **AI co-host** — pre-deposited balance, drawn down per minute; settlement is off the hot path.

Direct-to-Safe fees accumulate in the Safe treasury alongside the Seeder's treasury-half share; DAO governance can at any time move a batch of these into the buyback cycle.

---

## 9.4 Why Fees Don't Fork Across Chains

Fees collected on Polygon and HyperEVM (V15 Pool E HyperSkin, Pool F ShadowPass, Polygon Pool A–D) are bridged to the Arbitrum treasury Safe over the Chainlink CCIP mesh (§11.3) or LayerZero (for HyperEVM). The SDM buyback only executes on Arbitrum, where SDM/USDC has its canonical market. This is deliberate: multiple per-chain buyback sites would fragment liquidity and dilute the flywheel. One chain, one market, one buyback.

---

# 10. Ecosystem Platforms

| Platform | Status | Description |
|----------|--------|-------------|
| **ShadowVault V15** | LIVE (Arb/Poly/Hyper) | 9-vault USDC deposit-and-earn with live-value financial NFTs. See §3. |
| **ShadowzDex** | LIVE (Arb) | Intent DEX at [dex.diamondz.one](https://dex.diamondz.one), CCIP cross-chain mesh. See §7. |
| **EcosystemMarketplace + Lending** | LIVE (Arb/Poly) | NFT marketplace, NFT-backed lending, cross-chain position wrappers. See §6. |
| **Crabby Creator Ecosystem** | LIVE (Arb) | CRABBY v2, Crabby Social v2, Crabs in a Barrel, CrabbyTV. See §15. |
| **ShadowzDex Launchpad** | LIVE (Arb) | Position-NFT presales, yield sinks, durable registration. See §16. |
| **Streaming NFTs** | LIVE (Arb) | Content-bearing Position NFTs, holder-gated watch Worker. See §17. |
| **ShadowzPerps** | LIVE (HL) | Hyperliquid perps at [perps.diamondz.one](https://perps.diamondz.one), AI co-pilot + keeper. See §18. |
| **CrabbyTV** | LIVE | Live streaming, AI co-host, CRABBY token, FAST channels. See §8, §15. |
| **RetroSphere** | Planned | Retro gaming, RETRO token, Game Pool ETF baskets |
| **TheTube** | Planned | Film crowdfunding with CrowdfundEscrowV2 |
| **Beast DEX** | Referenced | 68-chain aggregator on Arbitrum |
| **DZX Exchange** | Planned | Hybrid DEX on DiamondzChain: AMM pools + bonding curves |
| **40AC** | Partnership | Real estate tokenization on DiamondzChain |
| **OnlyCryptoShells** | In development | Patreon-style crypto membership, tier model + Arb+USDC allowance + keeper recurring |
