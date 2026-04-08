---
cover: .gitbook/assets/diggaz_reward_nft.jpg
coverY: 0
---

# Economic Model for Decades of Solvency

## How We Stay Sustainable Forever

### The Real Picture: Revenue Tied to Product Usage

Most projects fail when token value is disconnected from real activity.
Diamondz Shadow is structured around **product-linked transaction flow** with explicit value routing.

In the current model:

- **CRABBY ($Crabby)** captures qualifying CrabbyTV platform transaction flow.
- **SDM ($SDM)** captures network and exchange-aligned value (including zdiamondex.store-linked activity).
- **wSDM / gSDM / sSDM** provide secure, collateralized SDM extension products.

This split keeps attribution auditable and governance-manageable.

### Web2 Surface, Web3 Rail Operating Model

The live system is intentionally staged:

- **Web2 surface**: gifts, badges, balances, creator earnings.
- **Web3 rail**: optional wallet payouts, batched on-chain settlement, and treasury routing.

Users are not forced to buy crypto to use product features.
Crypto appears as an optional payout and settlement rail.

#### Baseline Operating Numbers (Reference Scenario)

| Metric | Value |
|---|---|
| Active monthly users | 10,000 |
| Average monthly gifting per user | $12 |
| Monthly gross gifting volume | $120,000 |
| Platform share (20%) | $24,000/month |
| Creator share (80%) | $96,000/month |
| Creator crypto withdrawal rate (optional) | 40% of creator payouts |
| Monthly crypto payout flow (derived) | $38,400/month |
| Annualized gross gifting volume | $1,440,000 |
| Annualized platform share | $288,000 |
| Annualized creator share | $1,152,000 |
| Annualized crypto payout flow (derived) | $460,800 |

These are reference planning numbers, not guaranteed outcomes.

### Settlement and Payout Mechanics

#### Mirror-Ledger Settlement

1. User purchases gifts/credits through fiat rails.
2. Internal balances update instantly.
3. Backend keeps reserve mirror accounting.
4. Settlement is reconciled in controlled batches (for example weekly).

This lowers gas overhead while preserving mainstream UX.

#### Creator Payout Options (Crypto Optional)

- ACH / bank rails
- Stripe/PayPal-compatible rails
- USDC wallet withdrawal
- SDM wallet withdrawal (optional)

An optional **2% payout bonus** can be used as an adoption incentive on approved crypto rails.

### Revenue Structure Across Ecosystem Projects

Current ecosystem products:

- **CrabbyTV** (primary qualifying transaction-capture surface)
- **TheTube**
- **OnlyShellz**

#### 1) CrabbyTV Revenue and Capture

CrabbyTV currently anchors qualifying transaction flow through:

- films and premieres
- Spades and competitive game interactions
- AMA sessions
- paid creator interactions
- NFT-linked creator activity

Within governance policy, selected feature classes can apply a **3-6% fee band**.
A qualifying subset of these flows routes to `$Crabby` value pathways.

#### 2) TheTube and OnlyShellz Revenue Contribution

TheTube and OnlyShellz contribute to broader ecosystem revenue through creator monetization surfaces,
distribution channels, and engagement flows. Capture policy is governance-expandable and can route:

- treasury-directed platform fees
- payout/settlement infrastructure revenue
- analytics and validation service revenue

This structure allows cross-project growth without collapsing all revenue into one token rail.

#### 3) SDM Network + Exchange Revenue Rail

SDM captures value from:

- network gas activity
- infrastructure execution fees
- exchange/business-aligned flow at **https://zdiamondex.store/**

This rail remains distinct from `$Crabby` qualifying CrabbyTV capture.

#### 4) DeFi Vault Revenue Layer (Shadow Peoples Vault)

The Shadow Peoples Vault generates direct protocol revenue through two fee channels:

- **Withdrawal fees**: 1.2% standard service fee on all withdrawals; 0.9% on early exits (0.3% for DAW NFT holders) — see [Vault Whitepaper Section 5](shadow-peoples-vault.md) for fee design rationale
- **Yield performance fee**: 5% on all harvested Aave/lending yield

All vault protocol revenue flows through a revenue router that splits 50/50:
- **50% → SDM buyback** via DODO SDM/USDC pool, then seeded back as LP
- **50% → Treasury** (Gnosis Safe multisig)

This creates a self-reinforcing economic loop where vault growth deepens SDM liquidity,
strengthens governance, and attracts more vault deposits. As the vault expands to Solana,
Hyperliquid, and additional chains, each deployment adds a new revenue source flowing into
the same SDM flywheel.

**Vault revenue scales with TVL**: At $1M TVL with a blended 5% APY yield and average 1%
withdrawal fee, the vault generates approximately $25K/year in yield fees + withdrawal fees —
all of which drives SDM buy pressure and LP depth.

#### 4B) Yield Seeder as a Service (YSaaS)

The Yield Seeder architecture is licensable to external DeFi projects and DAOs, creating a
high-margin B2B revenue stream:

- **Deployment fees**: Per-chain contract deployment and configuration
- **Protocol fee share**: Configurable basis points on yield harvested by client vaults
- **Keeper hosting**: Managed infrastructure for automated rebalancing, harvesting, and buyback execution
- **Consulting**: Custom basket design, governance module configuration, and strategy optimization

YSaaS revenue is SDM-aligned: licensing fees and protocol shares flow through the treasury
and buyback pathways, reinforcing the core flywheel.

#### 5) Wrapper and Liquidity Revenue Layer

Secure wrappers (`wSDM`, `gSDM`, `sSDM`) generate policy-managed fee pathways via:

- mint/redeem fees
- DEX/liquidity activity (0.3% swap fee baseline per transaction, governance-adjustable)
- treasury-routed reinforcement programs

Wrapper contracts implement slippage checks, stale-price controls (3-hour threshold),
optional ratio enforcement, and restricted emergency withdrawal logic.

#### 6) Stock-Linked Wrapper Expansion (Gold/BTC + Tokenized Equities)

The same wrapper architecture can support governance-approved baskets that include tokenized stocks
alongside gold/BTC collateral rails.

Example structure:

- SDM + tokenized stock component
- SDM + gold-backed reserve component
- SDM + BTC-backed reserve component
- **40Acres (RWA)** wrapped with gold/BTC/stock-linked components under governance policy

Economic upside:

1. **Diversified return sources**: equity-style growth + hard-asset protection.
2. **Wider participant base**: attracts both crypto-native and portfolio-diversification users.
3. **Higher product depth**: enables multiple basket classes by risk profile.

Additional revenue lines created by stock-linked wrappers:

- primary mint/redeem fees on basket entry/exit
- secondary trading fees from DEX liquidity and routing
- strategy/index product fees for curated basket families
- analytics/data access fees for basket performance dashboards
- treasury routing gains from diversified collateral management
- 40Acres-specific wrapper product fees and liquidity incentives

### Treasury Model

#### Reference Allocation Framework

- **40%**: product/content/gaming reinvestment
- **20%**: technical development and infrastructure
- **15%**: community and contributor rewards
- **10%**: liquidity support
- **10%**: treasury reserves
- **5%**: buyback/burn or defensive market operations

Percentages are governance-adjustable with risk controls and disclosure.

#### Asset and Exposure Management

- operational stable reserve policy for payout continuity
- protocol-owned liquidity in key trading pairs
- diversified treasury exposure with governance limits
- incident reserves and insurance pathways for operational risk

### Cyclical Supply and Long-Run Stability

The emission design remains contribution-linked with cyclical controls:

1. controlled expansion
2. policy-driven contraction events
3. renewal cycles

This is intended to prevent uncontrolled inflation while preserving entry opportunities for new contributors.

### Compliance and Operational Safety

- clear terms: viewer credits are utility credits, not investment products
- creator KYC/KYB for payout access
- AML monitoring at scaled crypto-withdraw volume
- no guaranteed appreciation messaging
- segregated accounting between user funds and treasury strategy

### Economic Governance and Adaptation

Governance can tune:

- fee bands and qualifying-capture policy
- wrapper parameters and risk limits
- treasury allocation bands
- incentives (including optional withdrawal bonuses)
- rollout policy for TheTube/OnlyShellz capture integration

### Long-Term Solvency Metrics

Primary operating metrics:

1. runway and reserve months
2. revenue growth and retention
3. payout reliability and settlement accuracy
4. cross-project revenue diversification
5. wrapper risk and oracle freshness compliance
6. community value-capture ratio
7. token velocity and utility depth
8. stock-linked wrapper revenue contribution and diversification ratio
9. vault TVL growth and protocol revenue generation across chains
10. SDM buyback volume and DODO pool liquidity depth
11. Yield Seeder licensing client count and recurring fee revenue
12. vSDM governance participation rate and proposal throughput

By tying revenue to product behavior, separating value rails, and enforcing risk-managed treasury controls,
the model is designed for durable solvency over decades rather than speculation-driven cycles.
