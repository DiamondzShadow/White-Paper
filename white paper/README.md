### Diamondz Shadow White Paper (Current Model)

## CrabbyTV-First Structure with Split Token Value Rails

## Executive Summary

This whitepaper has been restructured to reflect the **current operating model**, not the older
token-first presentation.

The live model is organized around real product usage and clear value-routing:

1. **CrabbyTV product activity** (films, Spades, AMAs, paid events, creator interactions)
2. **Wavz validation and progression** (Milestone Units -> Creator Credits -> Reputation Badges -> Wavz Score)
3. **Split value capture rails**
   - **$Crabby**: captures qualifying CrabbyTV platform transaction flow
   - **$SDM**: captures network and exchange-aligned value (including flow tied to [zdiamondex.store](https://zdiamondex.store/))
4. **Secure SDM wrapper layer** (`wSDM`, `gSDM`, `sSDM`) for BTC/gold/USDC-backed upside exposure with hardened controls

This framing keeps platform behavior, economics, and contracts aligned in one readable flow.

### What Changed vs the Old Whitepaper Structure

- **From legacy model**: broad ecosystem-first, multi-token-first narrative.
- **To current model**: CrabbyTV product flow first, then token value capture and infrastructure.
- Legacy sections are retained for historical context but no longer define the primary reading order.

## Current Model Snapshot

### Product Layer (CrabbyTV)

- Creator monetization surfaces run through the CrabbyTV platform experience.
- Qualifying transaction classes are routed into CRABBY-aligned value accrual pathways.
- Feature policy and fee bands are governance-managed with explicit risk controls.

### Token Layer (Role Separation)

- **CRABBY ($Crabby)**: value capture from qualifying platform transactions.
- **SDM ($SDM)**: network gas token + exchange/business revenue rail.
- **wSDM / gSDM / sSDM**: SDM-centered wrappers with diversified reserve backing.

### Contract Safety Layer (Secure Wrappers)

The secure wrappers implement:

- Slippage protection (`min*Out` checks on mint/redeem)
- Fee-adjusted quote functions
- Stale-price protections (3-hour freshness threshold)
- Restricted emergency withdrawals (underlying assets only)
- Optional ratio enforcement (50/50 or 20/80 targets with tolerance)
- Pausable operations and treasury-routed fees

## Whitepaper Structure (Current Model Reading Order)

1. [Current Model Architecture (2026)](current-model-architecture.md)
2. [Introduction](introduction.md)
3. [Technology and Infrastructure](technology-and-infrastructure.md)
4. [Tokenomics](tokenomics.md)
5. [Economic Model for Decades of Solvency](economic-model-for-decades-of-solvency.md)
6. [Market Opportunity](market-opportunity.md)
7. [Roadmap](roadmap.md)
8. [How to Participate](how-to-participate.md)
9. [Quality Improvement Proposals (QIPs)](qips.md)
10. [Validator & Proof of Contribution Flow](validator-and-proof-of-contribution-flow.md)
11. [Legacy Model Context](diamondz-shadow-ecosystem.md)

## Key Innovations (Current Emphasis)

- **CrabbyTV Live Creator Progression** aligned to live platform behavior and monetization surfaces
- **Wavz Validation Layer** for verifiable creator progression and anti-fraud controls
- **$Crabby Transaction Capture Rail** for qualifying platform flows
- **$SDM Network + Exchange Rail** with explicit separation from CrabbyTV qualifying captures
- **Secure SDM Wrappers** (`wSDM`, `gSDM`, `sSDM`) with hardened mint/redeem protections
- **Diamond zChain Infrastructure** with strategic integrations (QuickNode, Thirdweb, Uniblock, Lucid Labs)

## Strategic Partnerships

Diamondz Shadow is powered by leading Web3 infrastructure providers:

### QuickNode - RPC Infrastructure
- **Partnership**: [quicknode.com](https://www.quicknode.com/)
- **Role**: Enterprise-grade RPC nodes for oracle validators
- **Value**: 99.9% uptime, sub-50ms response times, 1M+ requests/day capacity
- **Integration**: Oracle validators connect via QuickNode for fast Milestone Unit recording

### Thirdweb - Creator Onboarding & Smart Contracts
- **Partnership**: [thirdweb.com/diamond-zchain](https://thirdweb.com/diamond-zchain)
- **Role**: Embedded wallets, gasless transactions, smart contract deployment
- **Value**: Email/social login, ERC-4337 account abstraction, 170+ wallet support
- **Integration**: Creator dashboard built on thirdweb SDK with embedded wallets

### Uniblock - Blockchain Data & Analytics
- **Partnership**: [uniblock.dev](https://www.uniblock.dev/)
- **Role**: Real-time blockchain data APIs for creator analytics
- **Value**: Unified API for all on-chain data, sub-second indexing, cross-chain aggregation
- **Integration**: Powers Wavz dashboards with real-time Milestone Units, Creator Credits, Reputation Badges, and Wavz Score tracking

### Lucid Labs - DeFi Liquidity Infrastructure
- **Partnership**: [app.lucidlabs.fi](https://app.lucidlabs.fi/)
- **Role**: AMM liquidity pools, creator token bonding curves, NFT-Fi for Reputation Badges
- **Value**: Instant liquidity, yield farming, Milestone Unit-backed lending
- **Integration**: Creator token launches and Reputation Badge NFT marketplace powered by Lucid Labs

**Partnership Synergy**: Thirdweb (onboarding) → QuickNode (blockchain) → Wavz oracles (validation) → Uniblock (analytics) → Lucid Labs (liquidity)


## Contact and Resources

- **Website**: [diamondzshadow.com](https://diamondzshadow.com)
- **GitHub**: [github.com/DiamondzShadow](https://github.com/DiamondzShadow)
- **Discord**: [discord.gg/diamondzshadow](https://discord.gg/diamondzshadow)
- **Twitter**: [@DiamondShadoM](https://twitter.com/DiamondShadoM)
- **Email**: [development@diamondzshadow.com](mailto:development@diamondzshadow.com)


## Legal Disclaimer

This white paper is for informational purposes only and does not constitute an offer to sell, a solicitation to buy, or a recommendation for any security. The information contained herein is subject to change and may be incomplete. Diamondz Shadow makes no representation or warranty as to the accuracy or completeness of the information.

© 2025 Diamondz Shadow. All rights reserved.
