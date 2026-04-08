---
cover: .gitbook/assets/Untitled.jpeg
coverY: 0
---

# Diamondz Shadow Ecosystem

#### Diamondz Shadow Ecosystem

### Overview of the Ecosystem

> **Context note:** This chapter is retained as legacy ecosystem context.
> The current operating model is defined in `current-model-architecture.md` and the updated Executive Summary.
> Canonical token/value routing for current operations is:
> **$Crabby** (qualifying CrabbyTV flow), **$SDM** (network/exchange flow), and secure wrappers
> **wSDM/gSDM/sSDM** for SDM-collateralized extension.

Diamondz Shadow runs as a product-first creator ecosystem with explicit value routing and governance controls.
Current project surfaces are:

- **CrabbyTV** (primary qualifying transaction-capture surface)
- **TheTube**
- **OnlyShellz**

### Current Ecosystem Structure

#### 1) Product Layer

Users and creators engage through films/premieres, live sessions, Spades and competitive formats,
AMAs, paid interactions, and creator monetization tools.

#### 2) Validation Layer (Wavz)

Creator progression and trust are structured through:

- Milestone Units
- Creator Credits
- Reputation Badges
- Wavz Score

#### 3) Value-Rail Layer

- **$Crabby** captures qualifying CrabbyTV transaction flow.
- **$SDM** captures network and exchange-aligned value flow (including zdiamondex.store-aligned activity).
- **wSDM / gSDM / sSDM** provide secure SDM wrapper extension rails.

#### 4) Infrastructure and Governance Layer

Diamond zChain, oracle systems, treasury policy, and governance workflows execute and audit the model.

### Wrapper Expansion Upside: Tokenized Stocks + Gold/BTC

The wrapper architecture can be expanded through governance to include stock-linked baskets combined with
gold/BTC collateral components.

Potential basket pattern examples:

- SDM + tokenized large-cap stock + BTC
- SDM + tokenized growth stock + gold
- SDM + sector stock basket + BTC/gold hedge mix
- **40Acres (RWA)** + gold + BTC + tokenized stock overlays

Key upside drivers:

1. **Diversified exposure**: balances growth-linked equity behavior with hard-asset hedges.
2. **Richer product suite**: supports multiple basket classes by risk profile.
3. **Broader user fit**: serves users seeking non-single-asset exposure inside a crypto-native format.
4. **Treasury resilience**: diversified reserve composition can improve stress-period stability.

### DeFi Vault Layer (Shadow Peoples Vault)

The ecosystem now includes the **Shadow Peoples Vault**, a multi-chain DeFi basket vault protocol
that connects directly to SDM tokenomics:

- **User deposits** USDC → receives diversified basket exposure (70%) + lending yield (30%) + tradeable NFT position.
- **Protocol revenue** (withdrawal fees + 5% yield fee) flows through a revenue router:
  50% → SDM buyback via DODO pool + LP seeding, 50% → treasury.
- **vSDM governance** gives SDM holders direct on-chain control over vault parameters, baskets, fees, and treasury.
- **Yield Seeder** automates the buyback + LP seeding cycle and is designed as a licensable service for external projects.

Multi-chain deployments:
- **Arbitrum** (live V11): 0x API swaps, Aave V3 yield, 4-token basket
- **Solana** (Phase 2): Jupiter swaps, Kamino yield, 4 baskets
- **Hyperliquid** (Phase 3): HyperEVM DEX, HyperLend yield, 2 baskets
- **Robinhood Chain / Shido** (Phase 4+): EVM forks of V11

The vault creates a direct economic loop between DeFi activity and SDM value:
vault deposits → protocol fees → SDM buyback → deeper liquidity → stronger governance → better vault → more deposits.

For the full technical specification, see [Shadow Peoples Vault](shadow-peoples-vault.md).

### Revenue Integration (Different Revenue Lines)

The ecosystem is designed to generate multiple revenue channels instead of a single-source model:

1. **Project transaction capture**
   - qualifying CrabbyTV classes (policy-defined ranges)
   - governance-expandable TheTube/OnlyShellz modules
2. **Network and exchange rail revenue**
   - SDM-linked gas and execution activity
   - exchange/business-aligned flows
3. **Wrapper protocol revenue**
   - mint/redeem fees
   - liquidity and routing fees
4. **Stock-linked wrapper revenue (expansion)**
   - strategy basket issuance/redemption fees
   - index/analytics access and structured product pathways
   - dedicated 40Acres-wrapper revenue programs and liquidity markets
5. **Oracle and data services**
   - validation, fraud scoring, and API services
6. **DeFi vault protocol revenue**
   - withdrawal fees (0.3%–1.2% depending on lock tier and DAW NFT status)
   - 5% performance fee on harvested lending yield
   - 50% of all vault revenue drives SDM buyback + LP seeding
7. **Yield Seeder as a Service (YSaaS)**
   - deployment fees for external DeFi projects
   - ongoing protocol fee share on yield harvested by client vaults
   - keeper infrastructure hosting and monitoring
   - custom basket and strategy consulting

### Governance and Risk Controls

Governance controls:

- qualifying capture definitions and fee bands
- wrapper asset approvals and ratio limits
- oracle freshness and safety thresholds
- treasury allocation ranges and incident-response policy

Safety controls include slippage bounds, stale-price guards, pausable operations, and restricted emergency paths.

### Legacy Architecture Context

Historic references to TuBE, GaM3, and DuSTD are retained for design lineage.
They are not the canonical current-model rails unless explicitly reactivated by governance.
