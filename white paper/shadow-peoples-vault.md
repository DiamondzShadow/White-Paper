---
cover: .gitbook/assets/diggaz_reward_nft.jpg
coverY: 0
---

# Shadow Peoples Vault — Multi-Chain DeFi Basket Vault Protocol

**Technical Whitepaper v1.0**
Shadow Diamondz Game + Movie Development, Inc.
April 2026 — Yakini Crews, CEO & Co-Founder

---

## 1. Abstract

Shadow Peoples Vault is a multi-chain, multi-basket DeFi vault protocol built by Shadow Diamondz Game + Movie Development, Inc. It enables users to deposit stablecoins (USDC) and gain diversified exposure to curated crypto asset baskets while simultaneously earning yield through lending protocols. Each deposit mints a tradeable NFT position receipt, creating a liquid secondary market for vault positions.

The protocol launches on Arbitrum (live, V11) with planned expansion to Solana, Hyperliquid, Robinhood Chain, and additional EVM-compatible networks. Each chain deployment uses native swap aggregators (0x API on Arbitrum, Jupiter on Solana, HyperEVM DEX on Hyperliquid) and native lending protocols (Aave V3, Kamino/MarginFi, HyperLend) for maximum capital efficiency.

The vault architecture follows a **70/30 split model**: 70% of deposits are swapped into a chosen basket of tokens, while 30% is deployed into lending protocols to generate yield. A keeper bot automates rebalancing, yield harvesting, and basket drift correction across all chains.

---

## 2. Introduction

### 2.1 Problem Statement

DeFi users face several challenges: fragmented access to diversified crypto exposure, complex multi-step processes to build balanced portfolios, and the need to actively manage yield strategies across multiple protocols. Existing vault products typically offer single-asset strategies or require users to manually compose their desired exposure.

### 2.2 Solution

Shadow Peoples Vault solves these problems through:

- **Curated baskets** that provide one-click diversified exposure
- **Integrated yield engine** that earns passive returns on a portion of each deposit
- **Tradeable NFT position receipts** that create a secondary market
- **DAO governance** that allows community-driven basket and fee management
- **Multi-chain expansion** that brings the same vault experience across Arbitrum, Solana, Hyperliquid, and beyond

### 2.3 Design Principles

- **Non-custodial**: All assets remain in auditable smart contracts. Users maintain full control via their vault shares and position NFTs.
- **Chain-native**: Each deployment uses the best available infrastructure on that chain — no bridging, no wrapped assets, no cross-chain risk.
- **Composable**: Vault shares are ERC-20 tokens. Position NFTs are ERC-721. Both integrate with existing DeFi protocols and marketplaces.

---

## 3. Architecture

### 3.1 Core Flow

When a user deposits USDC into the vault, the system performs the following operations atomically:

1. Accept USDC deposit and mint vault shares (ERC-20) proportional to the current share price.
2. Mint a position NFT (ERC-721) recording the basket choice, deposit amount, lock tier, and timestamp.
3. Route 70% of the deposit to the **Basket Swapper**, which converts USDC into the chosen basket tokens via the chain-native swap aggregator.
4. Route 30% of the deposit to the **Yield Adapter**, which deploys USDC into the chain-native lending protocol.

### 3.2 Contract Architecture (Arbitrum V11)

| Contract | Address | Role |
|---|---|---|
| Vault V11 | `0x14f46cd4...9a6Aa` | Entry point, share accounting, deposit/withdraw |
| Swapper V3 | `0xD170902A...8f80E` | Basket token purchases via 0x API |
| vSDM Governance | `0x05D8d99F...4d6` | Vote-escrowed SDM wrapper |
| Timelock | `0x733E190C...3C4` | 48-hour execution delay |
| Governor | `0x4dA7349...Ca38` | On-chain proposal/voting (9% quorum) |
| Position NFT | `0xF206B54C...e7` | ERC-721 on-chain SVG receipt |
| Aave Adapter | `0x73650b47...ceD40` | USDC lending with tiered looping |
| Seeder | `0xc3ef5B6e...3A66` | SDM buyback + DODO LP seeding |

### 3.3 Basket Swapper

The Basket Swapper holds the token weight configuration for each basket. On deposit, it receives USDC from the vault and executes swaps according to the basket weights. All swaps route through the **0x Swap API v2** on Arbitrum, which aggregates pricing across all Arbitrum DEXes including Uniswap V3/V4, TraderJoe, Camelot, WOOFi, and Fluid.

A keeper bot monitors pending swaps every 30 seconds, fetches optimal 0x quotes, and executes transactions. For wBTC, the keeper uses an `includedSources` filter (TraderJoe_V2.1, PancakeSwap_V3, Uniswap_V3, WOOFi_V2) to avoid bad routing at small amounts. Rebalancing runs every 4 hours with a 5% drift threshold. Yield harvesting runs every 8 hours.

### 3.4 Yield Engine

30% of each deposit flows to the yield adapter, which deploys USDC into the chain-native lending protocol. On Arbitrum, this is **Aave V3** with E-Mode recursive lending tiers:

| Deposit Size | Strategy | Estimated APY |
|---|---|---|
| $5 – $99 | Simple supply (no loops) | ~2.5% |
| $100 – $999 | 1 leverage loop | ~4–5% |
| $1,000+ | 3 leverage loops | ~7–10% |

Yield accrues to the vault share price — when users withdraw, they receive more USDC than they deposited. A 5% protocol fee is taken on harvested yield.

---

## 4. Basket Strategies

### 4.1 Arbitrum Baskets (Live)

V11 currently runs a single configurable basket on Arbitrum. The DAO can add and modify baskets via governance proposals. The current default basket:

| Token | Weight | Category |
|---|---|---|
| wETH | 30% | Blue-chip L1 |
| wBTC | 15% | Store of value |
| PEPE | 15% | Community / meme |
| ARB | 10% | Arbitrum ecosystem |

The remaining 30% stays as USDC in the Aave yield adapter.
**Total: 70% basket + 30% yield = 100%.**

### 4.2 Solana Baskets (Phase 2)

The Solana vault is a separate Anchor program deployed natively on Solana — no bridging, no wrapped assets. It uses **Jupiter Swap V2 API** as the swap aggregator and **Kamino Finance** or **MarginFi** as the lending protocol.

**Basket S1 — Solana Blue Chip**: SOL 35%, JUP 15%, JTO 10%, PYTH 10% (basket 70%) + USDC yield 30%

**Basket S2 — Solana DeFi**: SOL 20%, RAY 15%, ORCA 15%, MNDE 10%, JUP 10% (basket 70%) + USDC yield 30%

**Basket S3 — Solana Meme & Community**: SOL 25%, BONK 15%, WIF 15%, JUP 10%, POPCAT 5% (basket 70%) + USDC yield 30%

**Basket S4 — Solana Infrastructure**: SOL 30%, HNT 15%, RENDER 15%, JTO 10% (basket 70%) + USDC yield 30%

#### Solana Technical Stack

- **Swap Aggregator**: Jupiter Swap V2 API — handles 50%+ of all Solana DEX volume, sub-second settlement, meta-aggregation across all Solana AMMs including Orca, Raydium, Meteora, and Lifinity. MEV protection via Jupiter Beam private relay.
- **Yield Protocol**: Kamino Finance (primary) or MarginFi — supply USDC to earn variable lending yield. Kamino offers integrated leverage vaults for enhanced returns.
- **Multisig**: Squads Protocol — Solana-native multisig equivalent of Gnosis Safe. 2-of-3 threshold for admin operations.
- **Keeper Bot**: TypeScript bot using `@jup-ag/api` and `@solana/web3.js`. Same pattern as the Arbitrum keeper: poll pending swaps, fetch Jupiter quotes, execute transactions, rebalance on drift.
- **Position Receipt**: SPL Token (fungible vault shares) + Metaplex NFT (position metadata with on-chain JSON). Tradeable on Tensor, Magic Eden.

### 4.3 Hyperliquid Baskets (Phase 3)

Hyperliquid is an EVM-compatible L1 optimized for trading. The vault deploys as a fork of the V11 Solidity contracts with minimal modifications, targeting HyperEVM for execution.

**Basket H1 — Hyperliquid Ecosystem**: HYPE 30%, PURR 15%, stHYPE 15%, ETH 10% (basket 70%) + USDC yield via HyperLend 30%

**Basket H2 — Cross-Chain Majors on HL**: ETH 25%, BTC 20%, SOL 15%, HYPE 10% (basket 70%) + USDC yield via HyperLend 30%

#### Hyperliquid Technical Stack

- **Swap**: HyperEVM native DEX or emerging aggregators on HyperEVM. Spot trading via Hyperliquid order book for major pairs.
- **Yield**: HyperLend — a decentralized lending protocol on HyperEVM with $337.8M TVL. Pooled lending market supporting WETH, WBTC, USDC, USDT in core pools, plus isolated pools for ecosystem tokens. Also available: Felix Protocol (CDP/feUSD), HypurrFi (Aave-fork with USDXL stablecoin).
- **Architecture**: Fork V11 Solidity contracts. Same Ownable2Step, same pausable/whitelist pattern, same 0x-style keeper bot pointing at HyperEVM RPC. Multisig via Safe on HyperEVM.

### 4.4 Future Chains (Phase 4+)

| Chain | Phase | Swap Infrastructure | Yield Protocol | Architecture |
|---|---|---|---|---|
| Arbitrum | LIVE | 0x API v2 | Aave V3 | Solidity V11 |
| Solana | Phase 2 | Jupiter Swap V2 | Kamino / MarginFi | Anchor program |
| Hyperliquid | Phase 3 | HyperEVM DEX | HyperLend | Fork V11 Solidity |
| Robinhood Chain | Phase 4 | TBD | TBD | EVM fork of V11 |
| Shido | Phase 5 | TBD | TBD | EVM fork of V11 |

---

## 5. Tokenomics & Revenue Model

### 5.1 SDM Token

SDM (`0x602b869eEf1C9F0487F31776bad8Af3C4A173394` on Arbitrum) is the native utility and governance token of the Shadow Diamondz ecosystem. Within the vault, it serves as:

- **Governance weight** via vSDM (vote-escrowed SDM)
- **Buyback target** for protocol revenue
- **LP incentive token** for the DODO SDM/USDC pool

### 5.2 Fee Structure

| Fee Type | Rate | Trigger |
|---|---|---|
| Early withdrawal (no DAW NFT) | 0.9% | Withdraw before lock tier completes |
| Early withdrawal (DAW NFT holder) | 0.3% | Withdraw before lock tier completes |
| On-time withdrawal | 1.2% | Withdraw after lock tier completes |
| Protocol yield fee | 5% | On harvested Aave/lending yield |
| Minimum deposit | $5 USDC | Per deposit |

### 5.3 Revenue Flywheel

All protocol revenue (withdrawal fees + 5% yield fee) flows through a **revenue router** that splits 50/50:

- **50% → SDM Buyback**: purchased via DODO pool, then seeded back as LP
- **50% → Treasury**: Gnosis Safe multisig

The buyback creates constant buy pressure on SDM while deepening DODO pool liquidity, creating a virtuous cycle.

### 5.4 Lock Tiers & Multipliers

| Tier | Lock Duration | Share Multiplier | Effect |
|---|---|---|---|
| FLEX | No lock | 1.0x | Withdraw anytime |
| Bronze | 30 days | 1.2x | 20% more shares per dollar |
| Silver | 90 days | 1.5x | 50% more shares per dollar |
| Gold | 180 days | 2.0x | 2x shares per dollar |
| Diamond | 365 days | 3.0x | 3x shares per dollar |

---

## 6. DAO Governance

The Shadow Peoples Vault is governed by a fully on-chain DAO built on OpenZeppelin Governor. The governance system gives vSDM holders direct control over all vault parameters, basket compositions, fee structures, and treasury allocation.

### 6.1 Governance Contract Registry

| Contract | Address | Role |
|---|---|---|
| vSDM | `0x05D8d99FEf3c93452e69b8a1d8B6B6241042F4d6` | Vote-escrowed SDM wrapper (ERC-20Votes) |
| Governor | `0x4dA73496D52DD67C9CfD8d910126aF183b16CA38` | Proposal creation, voting, execution |
| Timelock | `0x733E190C9283CF3d03Df0CAf3DBb50a70847E3C4` | 48-hour execution delay controller |

### 6.2 vSDM — Vote-Escrowed SDM

vSDM is an ERC-20Votes wrapper around the SDM token. Users wrap SDM 1:1 into vSDM to gain voting power. vSDM uses OpenZeppelin ERC20Votes with EIP-712 signature support, enabling gasless delegation and off-chain vote signing.

Key properties:

- 1:1 wrap/unwrap with no lock period (users can exit governance at any time)
- Voting power is snapshot-based (your power at the proposal creation block determines your vote weight)
- Delegation is supported (delegate your voting power to another address without transferring tokens)
- vSDM is transferable (governance power can be sold on secondary markets)

vSDM also serves as the share token for governance participation across the broader Shadow Diamondz ecosystem. Future products (DZX Exchange, CrabbyTV platform fees) can recognize vSDM holders for cross-protocol governance rights.

### 6.3 Governor Contract

The Governor contract is an OpenZeppelin Governor with GovernorVotes, GovernorVotesQuorumFraction, GovernorTimelockControl, and GovernorCountingSimple extensions. It manages the full proposal lifecycle:

1. **Proposal Creation**: Any address holding the minimum proposal threshold of vSDM can submit a proposal encoding one or more contract calls.
2. **Voting Delay**: 1-block delay after proposal creation before voting begins.
3. **Voting Period**: 7-day voting window. vSDM holders vote For, Against, or Abstain.
4. **Quorum Check**: Passes if For > Against AND total For + Abstain ≥ 9% of total vSDM supply at snapshot.
5. **Queue to Timelock**: Passed proposals are queued with a 48-hour delay.
6. **Execution**: After 48-hour delay, anyone can trigger execution.
7. **Cancellation**: Creator or Guardian (Gnosis Safe multisig) can cancel before execution.

### 6.4 Governance Parameters

| Parameter | Value | Notes |
|---|---|---|
| Quorum | 9% of vSDM supply | Minimum participation for valid vote |
| Voting period | 7 days | Time window for casting votes |
| Voting delay | 1 block | Delay before voting starts |
| Timelock delay | 48 hours | Safety window after vote passes |
| Proposal threshold | TBD (set on deployment) | Minimum vSDM to create proposal |
| Vote type | Simple (For/Against/Abstain) | Standard OZ counting |

### 6.5 Timelock Controller

The TimelockController is the actual owner of all vault contracts. When governance transfers ownership from the Gnosis Safe to the DAO, the Timelock address becomes the owner, meaning every admin function can only be called through a successful governance proposal + 48-hour delay.

The 48-hour delay serves a critical safety function: if the DAO passes a malicious or buggy proposal, users have 48 hours to withdraw their funds before the change takes effect.

**Roles**:
- `PROPOSER_ROLE` → Governor contract (only passed proposals can be queued)
- `EXECUTOR_ROLE` → `address(0)` (anyone can execute after delay)
- `CANCELLER_ROLE` → Guardian (Gnosis Safe) for emergency cancellation
- `ADMIN_ROLE` → self-held by Timelock initially, then renounced after setup

### 6.6 Governable Parameters

The DAO controls every meaningful parameter across all vault contracts:

**Vault Parameters**: Fee rates, deposit limits, whitelist, pause/unpause, basket swapper address, yield adapter address.

**Basket Parameters**: Token weights, add/remove tokens, create new baskets, rebalance thresholds.

**Revenue Parameters**: Revenue split ratio, buyback destination, treasury address.

**Yield Parameters**: Yield allocation percentage, loop tiers, harvest frequency.

### 6.7 Governance Transition Plan

| Phase | Model | Description |
|---|---|---|
| Phase 1 | Multisig (Current) | Gnosis Safe owns all contracts. Quick response to bugs and tuning. |
| Phase 2 | Hybrid | Safe transfers non-critical parameters to Timelock. Safe retains pause/emergency. |
| Phase 3 | Full DAO | Safe transfers all ownership to Timelock. Safe retains only CANCELLER_ROLE. |
| Phase 4 | Renounced | Safe renounces CANCELLER_ROLE. DAO is fully autonomous. |

### 6.8 Multi-Chain Governance

Each chain deployment has its own governance stack:

- **Arbitrum**: vSDM + Governor + Timelock (live)
- **Solana**: Squads multisig → Realms DAO (SPL Governance)
- **Hyperliquid**: Safe on HyperEVM → Governor fork

Cross-chain governance coordination is handled at the social layer initially, with on-chain cross-chain messaging (LayerZero or Wormhole) planned for Phase 4+.

### 6.9 Governance Security Considerations

- **Quorum attack protection**: 9% quorum prevents small-holder capture during low turnout (higher than the 2–4% common in most DeFi protocols).
- **Flash loan governance attacks**: vSDM uses ERC20Votes with block-based snapshots — voting power is determined at the proposal creation block, making flash-loan attacks impossible.
- **Timelock exit window**: 48-hour Timelock + 7-day voting period gives users 9+ days of warning for any parameter change.
- **Guardian safety valve**: Gnosis Safe retains CANCELLER_ROLE during Phases 2–3 for emergency cancellation, renounced in Phase 4.

---

## 7. Security

- **Ownable2Step**: Two-step ownership transfer prevents accidental loss of control.
- **Pausable**: Vault can be paused by owner or DAO in an emergency, freezing deposits and withdrawals.
- **Whitelist**: Deposits gated by whitelist during early launch; DAO can open to all.
- **Minimum Deposit**: $5 USDC minimum prevents dust attacks and ensures gas efficiency.
- **Reentrancy Protection**: All state-changing functions use OpenZeppelin ReentrancyGuard.
- **Dead Shares**: 1,000 dead shares minted on initialization to prevent the ERC-4626 inflation attack.
- **Gnosis Safe**: Vault owner is a 2-of-3 Gnosis Safe multisig (`0x2674bB72...0A6F`). After full testing, ownership transfers to the DAO Timelock.
- **Keeper Bot Safety**: Gas balance checked before every transaction; skips if ETH < 0.00005. Pending swaps retried every 30 seconds with exponential backoff.

---

## 8. Position NFT

Every deposit mints an ERC-721 position NFT with fully on-chain SVG art. The NFT encodes:

- Basket name and token composition
- Deposited USDC amount
- Vault shares received
- Lock tier and unlock timestamp
- Current USD value (updated on-chain)
- Share multiplier

The NFT is tradeable on OpenSea, Blur, and any ERC-721 marketplace. Selling the NFT transfers the claim to the underlying vault position. The buyer can withdraw the position value at any time (subject to lock tier rules).

---

## 9. Shadow Diamondz Ecosystem Integration

The vault sits at the center of the Shadow Diamondz DeFi ecosystem:

- **SDM Token**: Native governance and utility token across all Shadow Diamondz products.
- **DODO SDM/USDC Pool**: Protocol revenue buys SDM and seeds this pool, creating deep liquidity.
- **DiamondzChain (Chain ID 7791)**: Arbitrum Orbit AnyTrust L3 where bridged vault share tokens can be used in the DZX exchange ecosystem.
- **CrabbyTV**: Live streaming platform whose creator economy generates data for the WAVS intelligence layer.
- **WAVS/SPARKS**: Real-time data intelligence and event-based execution triggers that feed into vault yield optimization and prediction markets.
- **Bridge System**: BridgeLock/BridgeMint architecture enables vault share tokens to move between Arbitrum and DiamondzChain.

---

## 10. Yield Seeder — Infrastructure as a Service

The Seeder contract (`0xc3ef5B6e...3A66`) powers the vault's SDM buyback and DODO LP seeding cycle. The underlying Yield Seeder architecture is designed to be **offered as a white-label service** to other DeFi projects and DAOs looking for turnkey vault + yield + buyback infrastructure.

### 10.1 What the Yield Seeder Does

1. Collects protocol revenue (withdrawal fees + yield fees).
2. Splits revenue per governance ratio (default 50/50).
3. Executes market buyback of the project's native token through a designated liquidity pool.
4. Seeds purchased tokens back into the pool as LP, deepening liquidity.
5. Routes the remaining share to the project treasury.

### 10.2 Yield Seeder as a Service (YSaaS)

Shadow Diamondz can license or deploy the Yield Seeder infrastructure for external projects:

| Service Tier | Included | Target Audience |
|---|---|---|
| **Starter** | Seeder contract deployment + revenue router + basic keeper | Small DAOs and community tokens |
| **Growth** | Starter + multi-basket vault + Aave/lending adapter + position NFT | Mid-size DeFi projects |
| **Enterprise** | Growth + multi-chain deployment + custom governance + white-label UI | Protocols and institutional treasuries |

**Revenue model for YSaaS**:
- Deployment fee per chain
- Ongoing protocol fee share (configurable basis points on yield harvested)
- Keeper infrastructure hosting and monitoring
- Custom basket and strategy consulting

### 10.3 Why External Projects Benefit

- **Instant buyback flywheel**: Protocol revenue automatically strengthens their native token.
- **Deeper LP**: Seeded liquidity reduces slippage for traders and holders.
- **Diversified treasury**: The 70/30 basket-yield split gives project treasuries diversified exposure instead of holding 100% native token.
- **Governance-ready**: vSDM-style governance module can be forked for any ERC-20 token.
- **Audited contracts**: Battle-tested on Arbitrum V11 before external deployment.

---

## 11. Roadmap

| Phase | Timeline | Deliverables |
|---|---|---|
| V11 Launch | Q2 2026 | Arbitrum vault live, 4-token basket, Aave yield, position NFT, DAO governance |
| Solana Vault | Q3 2026 | Anchor program, Jupiter swaps, Kamino yield, 4 Solana baskets |
| Hyperliquid Vault | Q4 2026 | Fork V11 for HyperEVM, HyperLend yield, 2 HL baskets |
| Cross-Chain UI | Q4 2026 | Unified Lovable/Thirdweb frontend across all chains |
| Additional Chains | 2027 | Robinhood Chain, Shido, and community-voted chains |
| Advanced Strategies | 2027 | Auto-rebalancing algorithms, AI-driven basket optimization via WAVS |
| Yield Seeder Licensing | 2027 | YSaaS public offering for external projects and DAOs |

---

## 12. Conclusion

Shadow Peoples Vault represents a new paradigm in DeFi vault design: multi-chain native deployments with curated basket strategies, integrated yield, and community governance. By deploying chain-native programs on each target network (Anchor on Solana, Solidity on EVM chains), the protocol avoids bridge risk while offering a unified user experience.

The 70/30 basket-yield split, combined with NFT position receipts and the SDM revenue flywheel, creates a self-reinforcing ecosystem where vault growth deepens SDM liquidity, which strengthens governance, which improves vault parameters, which attracts more deposits.

The Yield Seeder architecture — proven internally on the vault — opens a new revenue line as a licensable service for other projects, positioning Shadow Diamondz not just as a vault operator but as DeFi infrastructure provider.

Shadow Diamondz is building the infrastructure for the next generation of accessible, diversified DeFi products — starting with the vault, expanding across chains, and integrating with the broader entertainment and data intelligence ecosystem.

---

**Contact**: Shadow Diamondz Game + Movie Development, Inc.
**Website**: [shadowdiamondz.com](https://shadowdiamondz.com) | **Chain**: DiamondzChain (ID 7791) | **RPC**: `rpc-mainnet.diamondz.baby`
