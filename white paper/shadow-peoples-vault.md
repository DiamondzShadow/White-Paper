# 3. Shadow Peoples Vault V11

The Shadow Peoples Vault V11 is a position-based DeFi vault on Arbitrum One. Users deposit USDC, choose a basket strategy and lock tier. The vault automatically splits each deposit: 70% purchases curated basket tokens via 0x swap aggregator, 30% earns yield in Aave V3 lending.

---

## 3.1 Architecture

| Contract | Address | Role |
|----------|---------|------|
| Vault V11 | `0x14f46cd4947b43258A516070483cCcf80E79a6Aa` | Core deposit/withdraw, position tracking |
| Swapper V3 | `0xD170902AfC2A16232CB91140dcCdC96901E8f80E` | 0x API basket swaps, rebalancing |
| Aave Adapter | `0x73650b4716e2F8b44169a4bF9756f155F7bceD40` | E-Mode recursive lending for yield |
| Position NFT | `0xF206B54C7658A45558365738CC1eF7Bfe717C4e7` | ERC-721 receipt with on-chain SVG art |
| Seeder V2 | `0x23e48B14177b6288b5c961d3000CD2666bdc2550` | Revenue router: SDM buyback + DODO LP |

---

## 3.2 Basket Strategies (Arbitrum — Live)

| Basket | Tokens | Weights |
|--------|--------|---------|
| A: Blue Chip + Meme | WETH, WBTC, PEPE, ARB | 30%, 15%, 15%, 10% + 30% yield |
| B: Diversified + Gold | WETH, WBTC, XAUT, LINK | 25%, 15%, 15%, 15% + 30% yield |
| C: DeFi Alpha | WETH, WBTC, PENDLE, GMX | 25%, 15%, 15%, 15% + 30% yield |

All basket swaps use the 0x API aggregator for best execution. The keeper bot monitors drift every 4 hours and rebalances when any token deviates more than 5% from target weight.

---

## 3.3 Yield Engine

30% of each deposit flows to the Aave V3 adapter using E-Mode recursive lending (stablecoin-to-stablecoin, 97% LTV):

| Deposit Size (30% portion) | Strategy | Estimated APY |
|---------------------------|----------|---------------|
| $5 – $99 | Simple supply (no loops) | ~2.5% |
| $100 – $999 | 1 leverage loop | ~4–5% |
| $1,000+ | 3 leverage loops | ~7–10% |

### 3.3.1 Risk Management — Leveraged Lending

The recursive lending strategy introduces leverage risk managed through multiple safeguards:

**E-Mode Self-Hedging:** Both supply and borrow are USDC-denominated. Price volatility in the broader crypto market does not directly affect the health factor.

**Automated Health Monitoring:** The keeper bot monitors health factor every 30 seconds. If it drops below 1.5, automated deleveraging triggers — unwinding loops in reverse order until health factor returns above 2.0.

**Controlled Loop Depth:** Maximum 3 loops at ~97% borrow per iteration, resulting in effective leverage of ~3.3x — well within E-Mode safety margins.

**Emergency Deleveraging:** The Aave adapter has an emergency `withdraw()` that unwinds all loops instantly. The admin multisig can trigger this without waiting for DAO governance.

| Risk Parameter | Value |
|---------------|-------|
| Maximum loops | 3 |
| Effective leverage | ~3.3x |
| E-Mode LTV | 97% |
| Liquidation threshold | 98% |
| Health monitor interval | 30 seconds |
| Deleverage trigger | Health factor < 1.5 |
| Emergency unwind | Admin multisig (instant) |

---

## 3.4 Fee Structure

| Fee Type | Rate | When |
|----------|------|------|
| Early exit (no DAW NFT) | 0.9% | Withdraw before lock expires |
| Early exit (DAW NFT holder) | 0.3% | Withdraw before lock, holds DAW NFT |
| On-time / FLEX withdrawal | 1.2% | Withdraw after lock or FLEX tier |
| Protocol yield fee | 5% | Of harvested Aave yield |

**Fee Design Rationale:** The on-time withdrawal fee (1.2%) is intentionally higher than the early exit fee (0.9%). The lock tier multiplier — not the fee differential — is the primary incentive for long-term deposits. A 365-day depositor receives 3.0x shares per dollar, while FLEX receives 1.0x. Breaking a lock early forfeits the multiplier advantage, which represents a far larger cost than the 0.3% fee differential. The on-time fee is the standard protocol service fee applied to all withdrawals including FLEX tier.

---

## 3.5 Lock Tiers & Multipliers

| Tier | Lock Duration | Share Multiplier |
|------|--------------|------------------|
| FLEX | None | 1.0x |
| 30 Day | 30 days | 1.2x |
| 90 Day | 90 days | 1.5x |
| 180 Day | 180 days | 2.0x |
| 365 Day | 365 days | 3.0x |

---

## 3.6 Position NFT

Every deposit mints an ERC-721 NFT with on-chain SVG art showing basket type, lock tier, deposited amount, and current value. The NFT is tradeable on OpenSea. Selling the NFT transfers the vault position to the buyer.

---

## 3.7 Token Tester

Before the DAO adds a new token to a basket, it must pass the Token Tester — a tool that runs buy/sell quotes through the 0x API at 7 dollar amounts ($1–$1,000) and generates a verdict: APPROVED, CAUTION, LOW LIQUIDITY, or REJECTED.
