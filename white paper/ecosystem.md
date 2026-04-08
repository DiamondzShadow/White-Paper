# 8. CrabbyTV Platform

CrabbyTV is a live streaming platform with Agora SDK, virtual gift/tipping system, co-host multi-video grid, and FAST channel distribution (Roku, Fire TV, Apple TV).

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
| CrabbyToken | `0x33e3DdD8d9952DE9D8D005529F844c8d9c14f3Af` | Platform utility token |
| CrabbyPoolV1 | `0x12470c8ce5e5CbBaF4367b65ee42Ee2E8Db86812` | WETH/PGOLD/wSOL 3-asset pool |
| CrabbyLPFarm | `0xf5ca0303211f18E5a896e6D1478865b5F94cFa27` | Stake CRABLP, earn CRABBY |
| CrabbyMultiZap | `0xCf5c4A9C90c198E3bAf04c4fe682608D40409Bb9` | Single-asset entry via any token |

---

# 9. Revenue Flywheel

All protocol revenue (withdrawal fees + 5% yield fee) flows through Seeder V2:

- **50% → SDM Buyback** via DODO DPP pool → seeds SDM/USDC LP
- **50% → Treasury** (Gnosis Safe `0x6052C6559eD5e5CbE74Ac0D42205Ad4A1CFBEd43`)

This creates a self-reinforcing cycle: more deposits → more revenue → more SDM purchased → deeper DODO liquidity → stronger ecosystem → more deposits.

---

# 11. Ecosystem Platforms

| Platform | Description |
|----------|-------------|
| **CrabbyTV** | Live streaming, virtual gifts, CRABBY token, FAST channels |
| **RetroSphere** | Retro gaming, RETRO token, Game Pool ETF baskets |
| **TheTube** | Film crowdfunding with CrowdfundEscrowV2 |
| **Beast DEX** | 68-chain aggregator on Arbitrum with NFT marketplace |
| **DZX Exchange** | Hybrid DEX on DiamondzChain: AMM pools + bonding curves |
| **WAVS/SPARKS** | Real-time data intelligence → event triggers for DeFi |
| **40AC** | Real estate tokenization partnership on DiamondzChain |
