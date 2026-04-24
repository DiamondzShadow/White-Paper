---
cover: .gitbook/assets/diggaz_reward_nft.jpg
coverY: 0
---

# Tokenomics

> **Archived — Superseded by Whitepaper v3.0.** See [sdm-token.md](sdm-token.md) for the current token specification.

#### Tokenomics

### Current Value-Capture Architecture (Canonical Model)

The live token model is organized around **separated value rails** and **wrapper security**:

1. **CRABBY ($Crabby)** captures qualifying CrabbyTV platform transaction flow.
2. **SDM ($SDM)** captures network and exchange-aligned value flow.
3. **wSDM / gSDM / sSDM** extend SDM through multi-asset collateralized wrappers.

This chapter reflects the current operating model. Older multi-token expansion modules are treated
as legacy context unless reactivated by governance.

### Token Rails and Responsibilities

#### CRABBY ($Crabby): Qualifying Platform Transaction Rail

- Captures value from qualifying CrabbyTV transaction classes.
- Designed to align token accrual to real platform usage:
  - films and premieres
  - Spades and competitive interactions
  - AMA sessions
  - paid creator events and NFT-linked activity
- Feature-policy fee bands are governance-managed, with current reference policy in the 3-6% range for selected classes.

#### SDM ($SDM): Network + Exchange Rail

- Native gas token for Diamond zChain.
- Anchor token for ecosystem infrastructure and validator security.
- Revenue-aligned rail tied to exchange/business activity at **https://zdiamondex.store/**.
- Intentionally distinct from `$Crabby` qualifying platform-capture flow.

### SDM Secure Wrapper Layer (wSDM, gSDM, sSDM)

The ecosystem includes three production-oriented SDM wrapper contracts:

- **wSDM**: SDM + WBTC target composition (50/50 reference)
- **gSDM**: SDM + XAUT target composition (50/50 reference)
- **sSDM**: SDM + USDC target composition (20/80 reference)

As well as being the network token, SDM wrapped with gold, BTC, or USDC provides upside-oriented
exposure through collateral diversification while preserving SDM as the anchor asset.

#### 40Acres (RWA) Wrapper Expansion

The wrapper framework is designed to support a dedicated **40Acres (RWA)** product line where
40Acres exposure is wrapped with:

- gold-backed collateral components
- BTC-backed collateral components
- tokenized stock components

This enables RWA-linked basket products with diversified exposure profiles and additional
protocol revenue pathways (mint/redeem, liquidity, and data/strategy products).

#### Wrapper Safety Controls (Implemented)

1. **Slippage protection**
   - Mint and redeem require user-provided minimum outputs.
2. **Fee-adjusted quotes**
   - `quoteMint` and `quoteRedeem` return net user outputs after fees.
3. **Stale-price protection**
   - Oracle values must be fresh (3-hour threshold) and positive.
4. **Restricted emergency withdrawals**
   - Emergency transfer paths are restricted to underlying reserve assets.
5. **Optional ratio enforcement**
   - Configurable tolerance checks around target basket ratios.
6. **Operational controls**
   - Pause/unpause, role checks, and bounded parameter updates.

### Multi-Asset Wrapper Architecture

#### Core Concept

Users deposit a basket of base assets into non-custodial vault contracts.  
The vault locks collateral and mints a wrapper share token representing proportional ownership.

#### Mint and Redeem

- **Mint**: deposit base assets -> receive wrapper shares.
- **Redeem**: burn wrapper shares -> receive proportional SDM + backing assets from reserves.
- Value and reserves remain auditable through on-chain accounting.

#### Price Structure

Wrapper net asset value (NAV) reflects weighted exposure to the underlying basket.
Market price on DEX venues can diverge from NAV, while mint/redeem functionality creates
arbitrage pressure that improves price efficiency.

#### Liquidity and Trading

Representative pairs:

- wSDM / SDM
- wSDM / BTC
- wSDM / USDC
- wSDM / ETH

Liquidity providers supply wrapper + pair assets and earn pool fees.
Current DEX policy baseline uses a **0.3% swap fee per transaction** (governance-adjustable).

#### Fee Routing

Protocol and DEX fee flows are governance-routed to:

- treasury support and operations
- liquidity reinforcement
- buyback/burn programs (policy-controlled)
- contributor and staking pathways
- allocation of the 0.3% DEX swap fee pathway across LPs and treasury policies

### Revenue-Capture Mapping (Current Policy)

| Source Class | Primary Rail | Notes |
|---|---|---|
| CrabbyTV qualifying transaction classes | `$Crabby` | Includes selected feature classes (for example films, Spades, AMAs, paid events). |
| Network gas and protocol infrastructure flow | `$SDM` | Tied to network usage and protocol execution. |
| Exchange/business flow | `$SDM` | Aligned to zdiamondex.store business rail. |
| Wrapper mint/redeem and related liquidity pathways | SDM-aligned treasury paths | Governed fee routing and risk controls. |
| 40Acres (RWA) wrapper pathways | Wrapper/RWA treasury paths | Gold/BTC/stock-linked basket product fees and liquidity flows. |
| TheTube / OnlyShellz project monetization | Governance policy layer | Expansion capture policies can be activated by governance. |

### Web2 Surface, Web3 Rail Baseline Numbers

Reference operating scenario:

- Active monthly users: **10,000**
- Average monthly gifting per user: **$12**
- Monthly gross gifting volume: **$120,000**
- Platform share (20%): **$24,000/month**
- Creator share (80%): **$96,000/month**
- Optional creator crypto withdrawal participation: **40%**
- Derived on-chain payout flow: **$38,400/month**
- Optional rollout incentive: **2% payout bonus** on approved withdrawal rails

### Supply, Allocation, and Governance Parameters

#### SDM Reference Allocation

| Category | Allocation | Purpose |
|---|---:|---|
| Network Operations | 40% | Security, gas economics, and validator incentives |
| Community Rewards | 25% | Proof-of-Contribution and ecosystem participation |
| Treasury | 15% | Strategic development and stability operations |
| Team & Advisors | 10% | Core build and long-term execution |
| Initial Liquidity | 10% | Market bootstrapping and trading support |

#### Cyclical Supply Design (Reference)

1. Controlled expansion through contribution-linked emissions.
2. Strategic contraction events via policy-defined liquidity-side burns.
3. Renewal cycles to preserve long-run participation and avoid static saturation.

### Risk Controls

1. **Value-rail separation** keeps attribution auditable.
2. **Oracle freshness checks** reduce stale-pricing risk for wrappers.
3. **Pausable safety mechanisms** provide incident response controls.
4. **Governance controls** manage fee bands, ratio tolerances, and rollout policy.
5. **Compliance-first payout design** keeps fiat and crypto rails operationally separated.

### SDM and DeFi: The Vault Revenue Flywheel

SDM's utility extends beyond network gas and wrapper collateral. Through the **Shadow Peoples Vault**,
SDM becomes the economic anchor of a multi-chain DeFi basket vault protocol that generates continuous
demand and liquidity reinforcement.

#### How the Vault Connects to SDM

1. Users deposit USDC into the vault and receive diversified basket exposure (70%) plus lending yield (30%).
2. The vault collects protocol revenue from withdrawal fees and a 5% fee on harvested yield.
3. All protocol revenue flows through a **revenue router** that splits 50/50:
   - **50% → SDM Buyback**: Purchased via the DODO SDM/USDC pool, then seeded back as LP.
   - **50% → Treasury**: Gnosis Safe multisig for operations and development.
4. The buyback creates **constant buy pressure** on SDM while simultaneously deepening DODO pool
   liquidity — a self-reinforcing cycle where vault growth strengthens SDM, which strengthens governance,
   which improves vault parameters, which attracts more deposits.

#### vSDM — Vote-Escrowed SDM for Governance

SDM holders wrap their tokens 1:1 into **vSDM** (vote-escrowed SDM) to gain governance power over all vault parameters. vSDM uses OpenZeppelin ERC20Votes with EIP-712 signatures, enabling gasless delegation and snapshot-based voting.

vSDM governance controls:
- **Vault parameters**: fee rates, deposit limits, whitelist, pause/unpause
- **Basket parameters**: token weights, add/remove tokens, rebalance thresholds
- **Revenue parameters**: buyback/treasury split ratio, buyback destination pool
- **Yield parameters**: yield allocation percentage, lending loop tiers, harvest frequency

Governance operates through the Governor contract (9% quorum, 7-day voting period) with a 48-hour
Timelock delay before execution, giving users time to exit before any parameter change takes effect.

#### SDM Lock Tiers and Vault Share Multipliers

Vault depositors who lock positions receive share multipliers that increase effective yield:

| Tier | Lock Duration | Share Multiplier |
|---|---|---|
| FLEX | No lock | 1.0x |
| Bronze | 30 days | 1.2x |
| Silver | 90 days | 1.5x |
| Gold | 180 days | 2.0x |
| Diamond | 365 days | 3.0x |

This lock-tier system incentivizes long-term participation and reduces selling pressure on vault
positions and SDM alike.

#### Seeder Contract — Buyback + LP Seeding

The Seeder contract (`0xc3ef5B6e...3A66`) automates the revenue flywheel:

1. Collects accumulated protocol fees (withdrawal fees + yield performance fee).
2. Splits per governance-set ratio (default 50/50).
3. Executes SDM buyback on the DODO SDM/USDC pool.
4. Seeds purchased SDM back into the pool as LP, deepening liquidity.
5. Routes treasury share to the Gnosis Safe multisig.

The Seeder is a core protocol primitive — and its architecture is designed for external licensing.
See the Yield Seeder as a Service section in the vault whitepaper for details.

#### Yield Seeder as a Service (YSaaS) — Revenue Expansion

The Yield Seeder architecture is **offered as a white-label service** to other DeFi projects and DAOs:

- **Starter tier**: Seeder contract + revenue router + basic keeper
- **Growth tier**: Multi-basket vault + lending adapter + position NFT
- **Enterprise tier**: Multi-chain deployment + custom governance + white-label UI

This positions SDM not just as a governance and gas token, but as the anchor of a **DeFi infrastructure
licensing business** where external projects pay deployment fees and ongoing protocol fee shares,
all of which flow back through the SDM buyback flywheel.

### Revenue-Capture Mapping (Current Policy — Updated with Vault)

| Source Class | Primary Rail | Notes |
|---|---|---|
| CrabbyTV qualifying transaction classes | `$Crabby` | Includes selected feature classes (films, Spades, AMAs, paid events). |
| Network gas and protocol infrastructure flow | `$SDM` | Tied to network usage and protocol execution. |
| Exchange/business flow | `$SDM` | Aligned to zdiamondex.store business rail. |
| Wrapper mint/redeem and related liquidity pathways | SDM-aligned treasury paths | Governed fee routing and risk controls. |
| 40Acres (RWA) wrapper pathways | Wrapper/RWA treasury paths | Gold/BTC/stock-linked basket product fees. |
| **Vault withdrawal fees** | **SDM buyback (50%) + Treasury (50%)** | **Revenue router splits all vault protocol fees.** |
| **Vault yield performance fee (5%)** | **SDM buyback (50%) + Treasury (50%)** | **Harvested lending yield fee flows through revenue router.** |
| **Yield Seeder licensing (YSaaS)** | **SDM-aligned treasury + buyback** | **External project deployment and protocol fee shares.** |
| TheTube / OnlyShellz project monetization | Governance policy layer | Expansion capture policies activated by governance. |

### Legacy Expansion Context

Previous references to TuBE, GaM3, and DuSTD remain part of legacy architecture context.
They are not the canonical current-model value rails unless explicitly reactivated through governance.
