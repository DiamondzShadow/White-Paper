# 2. SDM Token

| Parameter | Value |
|-----------|-------|
| Name | Diamondz Shadow Game + Movies |
| Symbol | SDM |
| Standard | ERC677 (ERC20 + transferAndCall) |
| Address | `0x602b869eEf1C9F0487F31776bad8Af3C4A173394` (Arbitrum) |
| Decimals | 18 |
| Initial Supply | 4,000,000,000 |
| Maximum Supply | 5,000,000,000 |
| Chainlink CCIP | Compatible via BurnMintERC677 |

SDM implements role-based mint/burn access control, gamification milestone events, and cross-chain minting via Chainlink CCIP metadata. The contract tracks total minted per address and emits milestone events at 100M token thresholds.

---

## 2.1 Multi-Token Economy

| Token | Backing | Ratio | Purpose |
|-------|---------|-------|---------|
| **SDM** | — | — | Ecosystem governance + utility |
| **vSDM** | SDM 1:1 wrap | 100% SDM | DAO voting power (ERC20Votes) |
| **wSDM** | SDM + WBTC | 50/50 | Bitcoin-backed SDM basket |
| **gSDM** | SDM + XAUT | 50/50 | Gold-backed SDM basket |
| **sSDM** | SDM + USDC | 20/80 | Stablecoin-backed SDM basket |
| **DBV** | Multi-asset basket | Weighted | Diamond Basket Vault shares (ERC-4626) |
| **CRABBY** | — | — | CrabbyTV streaming platform token |
| **RETRO** | — | — | RetroSphere gaming token |

All backed tokens (wSDM, gSDM, sSDM) use Chainlink price feeds with staleness thresholds, configurable ratio enforcement, slippage protection, pausable emergency controls, and fee-adjusted pricing. Contracts are built on OpenZeppelin v4.9 with ReentrancyGuard.
