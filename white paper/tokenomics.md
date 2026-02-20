---
cover: .gitbook/assets/diggaz_reward_nft.jpg
coverY: 0
---

# Tokenomics

#### Tokenomics

### Current Value-Capture Architecture (Live Model)

The token structure is now interpreted through a **split value-capture model**:

1. **CRABBY ($Crabby)** captures qualifying CrabbyTV platform transaction flow.
2. **SDM ($SDM)** captures network and exchange-aligned value flow.
3. **SDM secure wrappers** provide structured upside extension with diversified reserve backing.

This chapter is intentionally ordered around the current model first. Legacy expansion modules remain documented
later in this chapter for continuity.

#### CRABBY ($Crabby): Qualifying Platform Transaction Capture

- Captures value from qualifying CrabbyTV transaction categories.
- Aligns token economics with real product usage (films, Spades, AMAs, paid interactions, NFT-linked activity).
- Designed for usage-driven accrual rather than speculation-only demand.

#### SDM ($SDM): Network Token and Exchange Revenue Rail

- Native gas token for Diamond zChain transactions.
- Separate value rail tied to exchange/business activity at **https://zdiamondex.store/**.
- Also acts as the anchor asset used in all secure wrapper basket designs.

### SDM Secure Basket Wrapper Layer (wSDM, gSDM, sSDM)

To strengthen treasury-backed token products and provide asset-diversified exposure, the ecosystem introduces
three hardened wrapper tokens:

* **wSDM (Wrapped SDM - Bitcoin Backed)**: 50% SDM + 50% WBTC target composition
* **gSDM (Gold-backed SDM)**: 50% SDM + 50% XAUT target composition
* **sSDM (Stable SDM)**: 20% SDM + 80% USDC target composition

These wrappers are designed with production-focused controls:

1. **Slippage protection enforced**
   * Mint includes minimum output controls (`minWsdmOut`, `minGsdmOut`, `minSsdmOut`)
   * Redeem includes minimum output controls for both SDM and backing asset
2. **Fee-adjusted quoting**
   * `quoteMint` and `quoteRedeem` expose net user output after protocol fees
3. **Stale price protection**
   * Oracle reads enforce freshness windows (3h default threshold) and reject invalid values
4. **Restricted emergency withdraw**
   * Emergency transfers are restricted to backing assets and SDM only
5. **Gas optimizations**
   * Oracle decimals are cached to reduce repeated read overhead
6. **Optional ratio enforcement**
   * wSDM/gSDM target 50/50 with configurable tolerance
   * sSDM targets 20/80 with configurable tolerance
7. **Operational safety controls**
   * Pausable operations, structured events, validation checks, and explicit admin controls

This wrapper model extends SDM into collateral-diversified instruments while preserving SDM as the core anchor asset.
As well as being the network token, SDM wrapped with gold, BTC, or USDC can provide additional upside exposure through
diversified reserve backing while remaining inside the Diamondz Shadow ecosystem.

### Multi-Asset Collateralized Wrapper Architecture (Structured Expansion)

The wrapped-token architecture is designed around vault-backed baskets where users deposit base assets into
non-custodial contracts and mint tradable composite units.

#### 1) Core Basket Concept

- User deposits a basket of base assets (for example SDM + BTC + gold token).
- Vault locks collateral on-chain.
- Composite wrapper token is minted to represent proportional vault ownership.

#### 2) Mint and Redeem Structure

- **Mint**: deposit basket assets -> mint composite wrapper shares.
- **Redeem**: burn composite wrapper shares -> receive proportional underlying assets.
- Redemption follows vault-share accounting, preserving collateral backing transparency.

#### 3) Multi-Price Exposure

Composite wrapper valuation reflects weighted exposure to:

1. SDM price
2. BTC price
3. Gold-token price (or other approved reserve asset)

Wrapper market price can deviate from NAV on DEXs, while mint/redeem mechanics support arbitrage-based
price-efficiency pressure.

#### 4) DEX and Liquidity Structure

Representative trading pairs include:

- wSDM / SDM
- wSDM / BTC
- wSDM / USDC
- wSDM / ETH

Liquidity providers supply wrapper + paired assets and earn pool fees.

#### 5) Fee Routing and SDM Reinforcement

DEX and protocol fees are routed through treasury policy to:

- SDM treasury support
- buyback/burn programs (governance controlled)
- staker and contributor reward pathways

This creates volume-linked reinforcement for SDM-centered ecosystem liquidity.

#### 6) Expansion Families

The architecture supports additional basket variants such as:

- SDM + BTC
- SDM + Gold
- SDM + tokenized real-world or financial assets (governance approved)

Each variant remains collateralized, redeemable, and independently tradable.

#### 7) Structural Layering

1. Base Assets (SDM, BTC, Gold, USDC, approved additions)
2. Vault Contracts (multi-asset locking and accounting)
3. Composite Wrapped Tokens (basket shares)
4. DEX Trading Pairs and LP markets
5. Fee Capture and SDM-aligned treasury routing

### Supporting Token Modules (Legacy Expansion Track)

The sections below are retained for expansion-path context and prior architecture continuity:

#### TuBE: Content Creation Token

* **Token Name**: TuBE Token
* **Token Symbol**: TuBE
* **Token Standard**: ERC-20
* **Function**: Content creation, community governance, and entertainment tokenization
* **Utility**: Fractional ownership of content streams, creator rewards, governance rights

#### GaM3: Gaming Interaction Token

* **Token Name**: GaM3 Token
* **Token Symbol**: GaM3
* **Token Standard**: ERC-20 with EIP-2612 permit functionality
* **Function**: Gaming activities, predictive betting, in-game asset ownership
* **Utility**: Player-to-player betting, tournament predictions, cross-game asset compatibility

#### DuSTD: Ecosystem Stablecoin

* **Token Name**: DuSTD Stablecoin
* **Token Symbol**: DuSTD
* **Token Standard**: ERC-20 with price feed oracles
* **Function**: Stable value transactions and revenue settlement
* **Peg**: 1:1 USD through algorithmic and collateral backing

### Wrapper Mechanics (How Mint and Redeem Work)

1. **Price Inputs and Normalization**
   - SDM side uses protocol SDM/USD pricing.
   - Backing-asset side uses oracle pricing (WBTC/USD, XAUT/USD, USDC/USD).
   - All prices are normalized into consistent USD precision before output calculation.
   - Oracle values must be fresh (3h max staleness) and strictly positive.

2. **Mint Flow (User Deposits SDM + Backing Asset)**
   - User submits deposit amounts and a minimum wrapper output.
   - Contract computes:
     - `sdmUsdValue`
     - `backingUsdValue`
     - `grossWrapperOut = (sdmUsdValue + backingUsdValue) * 1e12`
   - Mint fee is deducted:
     - `fee = grossWrapperOut * mintFee / 10_000`
     - `netWrapperOut = grossWrapperOut - fee`
   - Fee shares are minted to treasury, making mint/redeem fee accounting consistent.
   - Transaction reverts if `netWrapperOut < minOut`.
   - Optional ratio checks enforce the strategy target (50/50 or 20/80 with tolerance).

3. **Redeem Flow (User Burns Wrapper for Underlying Assets)**
   - User submits wrapper amount and minimum SDM/backing outputs.
   - Contract computes pro-rata reserve share from current reserves:
     - `assetOut = reserve * wrapperIn / totalSupply`
   - Redeem fee is deducted per asset and routed to treasury.
   - Transaction reverts if post-fee output is below user minimums.
   - Wrapper is burned and net assets are transferred to user.

4. **Quote Functions (User-Expected Net Output)**
   - `quoteMint` and `quoteRedeem` expose **post-fee** output.
   - This prevents UI/user mismatches between quoted and realized amounts.
   - Quotes and execution both rely on the same stale-price and validation logic.

5. **Operational Safety**
   - Emergency pause halts mint/redeem during anomalies.
   - Emergency withdraw is restricted to SDM/backing assets only.
   - Admin fee updates are capped to prevent abusive parameter changes.

6. **Simple Example (wSDM)**
   - If a user contributes USD-equivalent value of `750`, then:
     - Gross output is approximately `750 wSDM` (18-decimal token units)
     - At 1% mint fee, net output is approximately `742.5 wSDM`
   - User can protect execution with `minWsdmOut` so the transaction reverts if output degrades.

### Supply Management and Emissions

Our ecosystem implements innovative cyclical supply management across all tokens to ensure long-term sustainability:

#### Universal Cyclical Mechanism

1. **Expansion Phase**:
2. Tokens are minted through Proof of Contribution up to maximum caps
3. Minting follows controlled schedules based on ecosystem activity
4. **Contraction Phase**:
5. When total supply reaches maximum cap, burn events are triggered
6. 40% of tokens are burned from liquidity pools only
7. Individual user wallets are never affected by burns
8. **Renewal Phase**:
9. After burn events, minting resumes based on contribution
10. Cycles repeat to maintain economic sustainability

### Token Allocation and Distribution (Reference Framework)

#### SDM Token Allocation

| Category           | Allocation | Purpose                                   |
| ------------------ | ---------- | ----------------------------------------- |
| Network Operations | 40%        | Gas fee distribution and network security |
| Community Rewards  | 25%        | Proof of Contribution rewards             |
| Treasury           | 15%        | Ecosystem development and stability       |
| Team & Advisors    | 10%        | Core team and strategic advisors          |
| Initial Liquidity  | 10%        | DEX liquidity and market making           |

#### TuBE Token Allocation

| Category             | Allocation | Purpose                                |
| -------------------- | ---------- | -------------------------------------- |
| Creator Rewards      | 45%        | Content creator compensation           |
| Community Governance | 20%        | Governance participation rewards       |
| Content Funding      | 15%        | Production and development funding     |
| Platform Revenue     | 10%        | Revenue sharing from tokenized content |
| Strategic Reserves   | 10%        | Long-term ecosystem stability          |

#### GaM3 Token Allocation

| Category            | Allocation | Purpose                                   |
| ------------------- | ---------- | ----------------------------------------- |
| Gaming Rewards      | 40%        | Player achievements and tournament prizes |
| Betting Pools       | 25%        | Predictive betting and staking rewards    |
| Game Development    | 15%        | Funding for ecosystem games               |
| Cross-Game Assets   | 10%        | Interoperable gaming asset creation       |
| Gaming Partnerships | 10%        | Integration with major gaming titles      |

#### DuSTD Stablecoin Mechanism

* **Collateral Backing**: Diversified reserve of fiat currencies and liquid assets
* **Algorithmic Stability**: Smart contracts maintain USD peg through supply adjustments
* **Transparency**: Real-time reserve reporting and regular audits
* **Cross-Chain Functionality**: Available across multiple blockchain networks

### Token Utility Map (Core + Supporting Modules)

#### SDM Utility (Gas Token)

* **Transaction Fees**: Powers all Diamond zChain transactions
* **Network Security**: Validators stake SDM for network consensus
* **Cross-Chain Operations**: Facilitates EVM bridge and Solana CCTP transactions
* **Governance**: Network parameter voting and upgrade decisions

#### TuBE Utility (Content Token)

* **Content Tokenization**: Fractional ownership of entertainment streams
* **Creator Compensation**: Direct payments to content creators
* **Governance Rights**: Voting on content direction and platform features
* **Revenue Sharing**: Proportional distribution of advertising and subscription revenue
* **Premium Access**: Exclusive content and early access privileges

#### GaM3 Utility (Gaming Token)

* **Predictive Betting**: Stake on game outcomes and player performances
* **In-Game Assets**: True ownership of gaming items and achievements
* **Tournament Entry**: Participate in ecosystem gaming competitions
* **Cross-Game Compatibility**: Use assets across multiple compatible games
* **Play-to-Earn**: Earn tokens through gaming achievements and contributions

#### DuSTD Utility (Stablecoin)

* **Stable Transactions**: Volatility-free payments and settlements
* **Revenue Distribution**: Stable payments to creators and contributors
* **Fiat Bridge**: Seamless conversion between crypto and traditional finance
* **DeFi Integration**: Stable asset for yield farming and liquidity provision
* **Cross-Chain Stability**: Maintain purchasing power across all supported networks

### Proof of Contribution Mining (Expansion Framework)

Our unique Proof of Contribution system distributes tokens across all four categories based on valuable ecosystem contributions:

#### Content Contributions (TuBE Rewards)

* **Original Content Creation**: Films, music, videos, and other entertainment
* **Content Curation**: Identifying and promoting quality content
* **Community Building**: Growing and engaging content communities
* **Platform Promotion**: Expanding audience reach and engagement

#### Gaming Contributions (GaM3 Rewards)

* **Gaming Achievements**: Skill-based accomplishments in supported games
* **Tournament Participation**: Competing in ecosystem gaming events
* **Game Development**: Contributing to ecosystem game creation
* **Community Organization**: Building and managing gaming communities

#### Network Contributions (SDM Rewards)

* **Technical Development**: Blockchain and platform improvements
* **Network Security**: Validator operations and security contributions
* **Infrastructure Support**: Node operation and network maintenance
* **Cross-Chain Development**: Bridge and interoperability improvements

#### Ecosystem Contributions (Multi-Token Rewards)

* **Governance Participation**: Active participation in DAO decisions
* **Educational Content**: Creating tutorials and educational materials
* **Translation Services**: Multi-language platform support
* **Community Moderation**: Maintaining healthy community environments

### Cross-Chain Integration Economics

#### EVM Bridge Economics

* **Bridge Fees**: Small fees for cross-chain transfers support network operations
* **Liquidity Incentives**: Rewards for providing cross-chain liquidity
* **Security Staking**: Validators stake tokens to secure bridge operations
* **Arbitrage Opportunities**: Price differences across chains create trading opportunities

#### Solana Integration via Circle CCTP

* **USDC Liquidity**: Native USDC transfers maintain ecosystem liquidity
* **Cross-Community Access**: Tap into Solana's gaming and creator communities
* **DeFi Opportunities**: Access Solana's efficient DeFi protocols
* **Yield Optimization**: Deploy liquidity across both ecosystems for maximum returns

### Economic Sustainability Model

#### Revenue Generation

1. **Platform Transaction Revenue (Web2 Surface Baseline)**:
   - Reference operating split: **20% platform / 80% creator** on qualifying gifting and interaction flows
   - Within platform-side capture, feature classes can apply governance-defined fee bands (for example ~3% to ~6% for specific premium flows)
   - Feature-level fee policy remains governance-adjustable within published risk controls
2. **Gaming Revenue**: Fees from betting, tournaments, and in-game transactions
3. **Cross-Chain Fees**: Revenue from bridge operations and cross-chain services
4. **DeFi Yield**: Returns from treasury assets deployed in DeFi protocols
5. **Partnership Revenue**: Income from platform integrations and partnerships

#### Value Accrual Mechanisms

1. **Token Burns**: Regular burns from fee revenue across all tokens
2. **Staking Rewards**: Incentivize long-term holding and participation
3. **Governance Value**: Increased influence as platform grows
4. **Utility Expansion**: New use cases increase token demand
5. **Network Effects**: Growing user base increases all token values

#### CRABBY ($Crabby) Capture of Platform Transaction Flow

- A percentage of qualifying platform transactions is routed into CRABBY ($Crabby)-aligned value accrual pathways.
- This includes treasury-directed protocol fees and governance-directed mechanisms such as buyback/burn, liquidity support, and contribution rewards for the $Crabby economy.
- Design objective: as platform transaction volume grows (films, Spades, AMAs, paid events, NFT activity), $Crabby value capture scales with real usage rather than speculative-only demand.

#### SDM Revenue Source (zdiamondex.store)

- SDM monetization is positioned separately from CrabbyTV qualifying transaction flow.
- SDM revenue is tied to the exchange/business model at **https://zdiamondex.store/**.
- This creates a clear split: **$Crabby** captures qualifying CrabbyTV platform transactions, while **$SDM** captures exchange-linked revenue flow.

#### Risk Management

1. **Diversified Revenue**: Multiple income streams reduce single-point failures
2. **Stable Asset Backing**: DuSTD provides stability during market volatility
3. **Cross-Chain Redundancy**: Multi-chain presence reduces network risks
4. **Community Governance**: Decentralized decision-making prevents centralization risks
5. **Regular Audits**: Ongoing security and economic audits ensure system integrity

### Integration with Diamond zChain

As native tokens of Diamond zChain, our multi-token ecosystem benefits from:

1. **High Performance**: 100,000 TPS capacity supports massive user adoption
2. **Low Costs**: Sub-cent transaction fees enable microtransactions
3. **Arbitrum Security**: Inherits proven security from Arbitrum Nitro technology
4. **EVM Compatibility**: Seamless integration with existing Ethereum tools
5. **Cross-Chain Connectivity**: Native bridges to major blockchain networks

By implementing this comprehensive four-token model with specialized utilities, cyclical supply management, and robust cross-chain integration, the Diamondz Shadow ecosystem creates a sustainable economic foundation designed to support decades of growth in decentralized entertainment and gaming.
