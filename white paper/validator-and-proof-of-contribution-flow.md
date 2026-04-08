# VALIDATOR PROTOCOLS & PROOF OF CONTRIBUTION FLOW

> **Archived — Superseded by Whitepaper v3.0.** Bridge validator consensus is now documented in [diamondz-bridge.md](diamondz-bridge.md). The current whitepaper starts at [README.md](README.md).

## THE COMPLETE VISUAL FLOW

```
╔═══════════════════════════════════════════════════════════════════════╗
║                    DIAMONDZ SHADOW ECOSYSTEM FLOW                     ║
╚═══════════════════════════════════════════════════════════════════════╝

Step 1: CONTENT CREATION
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│  👤 CREATOR                →  📹 CONTENT  →  📊 METRICS            │
│                                                                     │
│  • Project Operator           • Events/Data   • Verifiable Signals │
│  • Musician                   • Music         • Views              │
│  • Gamer                      • Streams       • Engagement         │
│  • Developer                  • Code          • Contributions      │
│                                                                     │
└──────────────────────────────────┬──────────────────────────────────┘
                                   │
                                   ▼
                                   
Step 2: VALIDATOR PROTOCOL
┌─────────────────────────────────────────────────────────────────────┐
│                        🤖 AI VALIDATOR                              │
│                                                                     │
│  MONITORS:                      VALIDATES:                         │
│  ✓ Social APIs                  ✓ Authenticity                     │
│  ✓ Sports/Event Feeds           ✓ No fraud                         │
│  ✓ Pricing Feeds                ✓ Real metrics                     │
│  ✓ Gaming/Dev APIs              ✓ Confidence score                 │
│                                                                     │
│  EVENT DETECTED! → NBA Outcome + Pricing Update Confirmed          │
│                                                                     │
│  ┌────────────────────────────────────────────┐                   │
│  │ Validation Confidence: 98% ✓               │                   │
│  │ Fraud Check: PASSED ✓                      │                   │
│  │ Duplicate Check: PASSED ✓                  │                   │
│  │ Time Stamp: 2025-10-09 14:23:45 UTC        │                   │
│  └────────────────────────────────────────────┘                   │
│                                                                     │
└──────────────────────────────────┬──────────────────────────────────┘
                                   │
                                   ▼
                                   
Step 3: ON-CHAIN RECORDING (ProjectOracleFeed.sol + platform adapters)
┌─────────────────────────────────────────────────────────────────────┐
│                      ⛓️  DIAMOND ZCHAIN                             │
│                                                                     │
│  struct OracleRecord {                                             │
│      marketId: "NBA_2026_02_20_LAL_BOS_WINNER"                    │
│      metricType: EVENT_RESULT                                      │
│      threshold: 1                                                  │
│      value: 1                                                      │
│      timestamp: 1771557825                                         │
│      validationConfidence: 98                                      │
│      verified: true  ✓                                             │
│  }                                                                 │
│                                                                     │
│  📝 IMMUTABLE RECORD CREATED                                       │
│  📍 Transaction Hash: 0xabc123...                                  │
│  🔒 Cannot be altered or deleted                                   │
│                                                                     │
└──────────────────────────────────┬──────────────────────────────────┘
                                   │
                                   ▼
                                   
Step 4: PROOF OF CONTRIBUTION CALCULATION
┌─────────────────────────────────────────────────────────────────────┐
│                    📈 CONTRIBUTION SCORE ENGINE                     │
│                                                                     │
│  FORMULA:                                                          │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  Total Score = α(Content) + β(Technical) + γ(Community) + δ(Econ)  │
│                                                                     │
│  WEIGHTS:                                                          │
│  α = 40%  Content Contribution                                     │
│  β = 25%  Technical Contribution                                   │
│  γ = 20%  Community Contribution                                   │
│  δ = 15%  Economic Contribution                                    │
│                                                                     │
│  ┌──────────────────────────────────────────────────────┐         │
│  │ YOUR BREAKDOWN:                                      │         │
│  │                                                      │         │
│  │ Content:    1000 pts × 0.40 = 400 pts ████████      │         │
│  │ Technical:   500 pts × 0.25 = 125 pts ███           │         │
│  │ Community:   300 pts × 0.20 =  60 pts ██            │         │
│  │ Economic:    200 pts × 0.15 =  30 pts █             │         │
│  │                                        ─────         │         │
│  │ TOTAL CONTRIBUTION SCORE:         615 points        │         │
│  └──────────────────────────────────────────────────────┘         │
│                                                                     │
└──────────────────────────────────┬──────────────────────────────────┘
                                   │
                                   ▼
                                   
Step 5: TOKEN REWARDS (BurnMintERC677.sol)
┌─────────────────────────────────────────────────────────────────────┐
│                       💰 AUTOMATIC MINTING                          │
│                                                                     │
│  BASE REWARD:           100 ZSDM                                   │
│  Confidence Bonus:     + 30 ZSDM (98% confidence)                  │
│  Community Boost:      + 20 ZSDM (active member)                   │
│  Streak Bonus:         + 15 ZSDM (consistent uploads)              │
│                         ─────────                                   │
│  TOTAL MINTED:          165 ZSDM  💎                               │
│                                                                     │
│  ✅ Minted to: 0x742d35Cc6634C0532925a3b8...                       │
│  ✅ Gas fees: PAID (creator pays nothing)                          │
│  ✅ Available: IMMEDIATELY                                         │
│  ✅ Vesting: NONE                                                  │
│                                                                     │
└──────────────────────────────────┬──────────────────────────────────┘
                                   │
                                   ▼
                                   
Step 6: CONTINUOUS LOOP
┌─────────────────────────────────────────────────────────────────────┐
│                      🔄 KEEP CREATING                               │
│                                                                     │
│  → Next Milestone: 5,000 Subscribers                               │
│  → Progress: 21% (1,047 / 5,000)                                   │
│  → Potential Reward: 500 ZSDM                                      │
│  → Keep creating content to earn more!                             │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## VALIDATOR TYPES & HOW THEY CONNECT

```
╔═══════════════════════════════════════════════════════════════════╗
║                      VALIDATOR HIERARCHY                          ║
╚═══════════════════════════════════════════════════════════════════╝

Level 0: BASE VALIDATORS (Consensus Layer)
┌────────────────────────────────────────────────────────────────┐
│  ⚡ CONSENSUS NODES  •  DECENTRALIZED  •  STAKE OR LP REQUIRED │
│                                                                │
│  ✓ Run by projects/communities using protocol                 │
│  ✓ Form consensus on validation results                       │
│  ✓ Minimum 50K ZSDM stake OR 100K in LP                      │
│  ✓ Earn protocol fees + validation rewards                    │
│                                                                │
│  OPERATES → Oracle infrastructure                             │
│  VALIDATES → Cross-checks all validator outputs               │
│  CONSENSUS → Multi-signature approval for high-value          │
│  EARNS → 10% of all minted tokens distributed to nodes        │
│                                                                │
│  NODE REQUIREMENTS:                                            │
│  • Uptime: 99%+ availability                                   │
│  • Stake: 50K ZSDM (lockup period: 90 days)                   │
│  • OR LP: 100K ZSDM worth in ZSDM/ETH pool                    │
│  • Hardware: 4 CPU, 16GB RAM, 500GB SSD                       │
│  • Network: Static IP, 100Mbps+                               │
│                                                                │
│  SLASHING CONDITIONS:                                          │
│  • Downtime > 1%: -5% stake                                    │
│  • False validation: -20% stake                               │
│  • Malicious behavior: -100% stake (permanent ban)            │
│                                                                │
│  WHY RUN A BASE VALIDATOR?                                     │
│  • Projects build nodes for their community                    │
│  • Earn sustainable revenue from protocol fees                │
│  • Participate in governance decisions                         │
│  • Support decentralization of the network                    │
│  • Cost to run: ~$100-200/month                               │
│  • Avg earnings: 500-2000 ZSDM/month                          │
└────────────────────────────────────────────────────────────────┘
                           │
                           ▼
Level 1: AI VALIDATORS (Automated)
┌────────────────────────────────────────────────────────────┐
│  🤖 ALWAYS ACTIVE  •  INSTANT  •  NO STAKING REQUIRED     │
│                                                            │
│  ✓ Monitors all platforms 24/7                            │
│  ✓ Validates milestones < 100K                            │
│  ✓ 95%+ accuracy rate                                     │
│  ✓ Confidence scoring (0-100%)                            │
│                                                            │
│  VALIDATES → Content metrics                              │
│  CHECKS → Fraud patterns                                  │
│  ASSIGNS → Confidence score                               │
│  TRIGGERS → On-chain recording                            │
└────────────────────────────────────────────────────────────┘
                           │
                           ▼
Level 2: ORACLE VALIDATORS (High-Value)
┌────────────────────────────────────────────────────────────┐
│  👁️ MANUAL REVIEW  •  HIGH-VALUE  •  10K ZSDM STAKE      │
│                                                            │
│  ✓ Reviews milestones > 100K                              │
│  ✓ Verifies disputed milestones                           │
│  ✓ Earns 5% of minted tokens                              │
│  ✓ Slashed for false validation                           │
│                                                            │
│  REVIEWS → AI validation                                  │
│  CONFIRMS → High-value achievements                       │
│  DISPUTES → Handles conflicts                             │
│  EARNS → Validation fees                                  │
└────────────────────────────────────────────────────────────┘
                           │
                           ▼
Level 3: COMMUNITY VALIDATORS (Future)
┌────────────────────────────────────────────────────────────┐
│  👥 PEER REVIEW  •  DECENTRALIZED  •  1K ZSDM STAKE       │
│                                                            │
│  ✓ Community-driven validation                            │
│  ✓ Builds reputation score                                │
│  ✓ Earns 2% of minted tokens                              │
│  ✓ Governance participation                               │
│                                                            │
│  VOTES → On disputed cases                                │
│  REVIEWS → Content quality                                │
│  MODERATES → Community standards                          │
│  GROWS → Validator reputation                             │
└────────────────────────────────────────────────────────────┘
```

---

## BASE VALIDATOR CONSENSUS MECHANISM

```
╔═══════════════════════════════════════════════════════════════════╗
║           HOW BASE VALIDATORS FORM CONSENSUS                      ║
╚═══════════════════════════════════════════════════════════════════╝

CONSENSUS MODEL: Proof of Stake + Proof of Validation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

For Standard Milestones (< 100K):
┌────────────────────────────────────────────────────────────┐
│  1. AI Validator detects milestone                         │
│  2. Base Validator Node receives validation request        │
│  3. Node independently verifies via API                    │
│  4. If confidence > 95%: Auto-approve                      │
│  5. Record on-chain with node signature                    │
│  6. Node earns validation fee (0.5% of minted tokens)      │
└────────────────────────────────────────────────────────────┘

For High-Value Milestones (> 100K):
┌────────────────────────────────────────────────────────────┐
│  1. AI Validator detects milestone                         │
│  2. Broadcast to ALL active Base Validator nodes           │
│  3. Each node independently verifies (5 min window)        │
│  4. Nodes submit signed validation votes                   │
│  5. Consensus threshold: 66% agreement required            │
│  6. Multi-sig approval from validator set                  │
│  7. Record on-chain with all signatures                    │
│  8. Participating nodes split 10% of minted tokens         │
└────────────────────────────────────────────────────────────┘

VALIDATOR SET SELECTION:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• Minimum 21 active Base Validators required for consensus
• Maximum 100 validators in active set at any time
• Selection based on:
  - Stake amount (50K-500K ZSDM)
  - Uptime history (99%+ required)
  - Validation accuracy (98%+ required)
  - Community reputation score
  
ROTATION & FAIRNESS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• Validators rotate in/out of active set every epoch (24 hours)
• Random selection weighted by stake amount
• Ensures all validators get fair opportunity to earn
• Prevents centralization and collusion

ORACLE COST DISTRIBUTION:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Running oracle infrastructure has costs:
• API calls: $0.001 per validation
• Server costs: $100-200/month per node
• Bandwidth: ~$20/month
• Monitoring tools: $30/month

Who pays?
├─ Protocol takes 2% of all minted tokens
├─ 1% goes to Base Validator pool
├─ 0.5% covers infrastructure costs
└─ 0.5% goes to protocol treasury

This makes running a node profitable while covering real costs.
```

---

## SETTING UP A BASE VALIDATOR NODE

```
╔═══════════════════════════════════════════════════════════════════╗
║         FOR PROJECTS BUILDING ON DIAMONDZ SHADOW                  ║
╚═══════════════════════════════════════════════════════════════════╝

WHY YOUR PROJECT SHOULD RUN A BASE VALIDATOR:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. REVENUE GENERATION
   • Earn 0.5-2% of all tokens minted through your validations
   • Average: 500-2000 ZSDM/month per node
   • Scales with network growth
   
2. SUPPORT YOUR COMMUNITY
   • Your users' milestones validated by your node
   • Build trust and reliability
   • Strengthen community bonds
   
3. GOVERNANCE POWER
   • Base Validators vote on protocol upgrades
   • Influence reward structures
   • Shape the future of the ecosystem
   
4. NETWORK DECENTRALIZATION
   • More validators = more secure network
   • Reduces single points of failure
   • Aligns with Web3 principles


SETUP GUIDE:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

STEP 1: MEET REQUIREMENTS
┌────────────────────────────────────────────────────────────┐
│  Minimum Stake: 50,000 ZSDM                                │
│  OR Liquidity Provision: 100,000 ZSDM worth in LP tokens   │
│                                                            │
│  Hardware:                                                 │
│  • CPU: 4 cores (8 recommended)                            │
│  • RAM: 16GB minimum (32GB recommended)                    │
│  • Storage: 500GB SSD (NVMe preferred)                     │
│  • Network: 100Mbps+ with static IP                        │
│                                                            │
│  Software:                                                 │
│  • Ubuntu 22.04 LTS or similar                             │
│  • Docker & Docker Compose                                 │
│  • Node.js 18+ (for validator client)                      │
│  • SSL certificate (Let's Encrypt)                         │
└────────────────────────────────────────────────────────────┘

STEP 2: STAKE OR PROVIDE LIQUIDITY
┌────────────────────────────────────────────────────────────┐
│  Option A: Direct Staking                                  │
│  $ validator-cli stake --amount 50000                      │
│  • Lockup: 90 days minimum                                 │
│  • Rewards: Start immediately                              │
│  • Unstaking: 7-day cooldown period                        │
│                                                            │
│  Option B: LP Provision (Higher Rewards)                   │
│  $ validator-cli lp-stake --pool ZSDM-ETH --amount 100000 │
│  • Earn LP fees + validation rewards                       │
│  • Lockup: 90 days minimum                                 │
│  • Higher APY (15-30% vs 10-20% staking)                   │
└────────────────────────────────────────────────────────────┘

STEP 3: DEPLOY VALIDATOR NODE
┌────────────────────────────────────────────────────────────┐
│  # Clone validator software                                │
│  git clone https://github.com/diamondz-shadow/validator    │
│  cd validator                                              │
│                                                            │
│  # Configure your node                                     │
│  cp .env.example .env                                      │
│  vim .env  # Add your settings                             │
│                                                            │
│  # Required environment variables:                         │
│  VALIDATOR_ADDRESS=0x...                                   │
│  STAKE_AMOUNT=50000                                        │
│  RPC_ENDPOINT=https://rpc.diamondz-shadow.io              │
│  PRIVATE_KEY=your_secure_key                               │
│  API_KEYS_YOUTUBE=...                                      │
│  API_KEYS_SPOTIFY=...                                      │
│  API_KEYS_TWITCH=...                                       │
│                                                            │
│  # Start validator                                         │
│  docker-compose up -d                                      │
│                                                            │
│  # Verify it's running                                     │
│  validator-cli status                                      │
└────────────────────────────────────────────────────────────┘

STEP 4: REGISTER ON-CHAIN
┌────────────────────────────────────────────────────────────┐
│  # Register your validator                                 │
│  validator-cli register \                                  │
│    --name "YourProject Validator" \                        │
│    --description "Supporting the community" \              │
│    --commission 5                                          │
│                                                            │
│  # Commission: Your fee (1-10%)                            │
│  # Recommended: 3-5% for community validators              │
│                                                            │
│  # Wait for activation (up to 24 hours)                    │
│  validator-cli check-status                                │
└────────────────────────────────────────────────────────────┘

STEP 5: MONITOR & MAINTAIN
┌────────────────────────────────────────────────────────────┐
│  # Check node health                                       │
│  validator-cli health                                      │
│                                                            │
│  # View earnings                                           │
│  validator-cli earnings                                    │
│                                                            │
│  # Update software (monthly)                               │
│  git pull && docker-compose up -d --build                  │
│                                                            │
│  # Monitoring dashboard                                    │
│  https://validator-dashboard.diamondz-shadow.io            │
└────────────────────────────────────────────────────────────┘


ECONOMICS FOR NODE OPERATORS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Monthly Costs:
├─ Server (VPS/Cloud): $100-150
├─ API calls: $30-50
├─ Bandwidth: $20
├─ Monitoring: $30
└─ Total: ~$180-250/month

Monthly Revenue (Average):
├─ Validation rewards: 500-1000 ZSDM
├─ Consensus participation: 200-500 ZSDM
├─ LP fees (if using Option B): 300-600 ZSDM
└─ Total: 1000-2100 ZSDM/month

At $1 ZSDM = $1 USD:
✓ Profit: $750-1850/month
✓ ROI on stake: 18-44% APY
✓ Payback period: 3-6 months

PLUS: Governance power & community benefits
```

---

## PROOF OF CONTRIBUTION BREAKDOWN

```
╔═════════════════════════════════════════════════════════════════════╗
║            HOW CONTRIBUTIONS TRANSLATE TO REWARDS                   ║
╚═════════════════════════════════════════════════════════════════════╝

1️⃣  CONTENT CONTRIBUTION (40% weight)
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    Project Validation Milestones  Points      Tokens
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    100 verified events           20          20 ZSDM
    500 verified events           50          50 ZSDM
    1,000 verified events        100         100 ZSDM
    5,000 verified events        500         500 ZSDM
    10,000 verified events     1,000       1,000 ZSDM
    50,000 verified events     5,000       5,000 ZSDM
    100,000 verified events   10,000      10,000 ZSDM
    1,000,000 verified events 100,000     100,000 ZSDM
    
    Multipliers:
    • High confidence (>95%): +50%
    • Consistent validator uptime (30-day): +10%
    • Multi-source corroboration: +25%

2️⃣  TECHNICAL CONTRIBUTION (25% weight)
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    Activity                   Points      Tokens
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Smart contract PR          500         125 ZSDM
    Critical bug fix         1,000         250 ZSDM
    Documentation update       100          25 ZSDM
    Infrastructure support   2,000         500 ZSDM
    Security audit report    5,000       1,250 ZSDM

3️⃣  COMMUNITY CONTRIBUTION (20% weight)
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    Activity                   Points      Tokens
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Help other creators         50          10 ZSDM
    Moderate community         200          40 ZSDM
    Onboard new user           100          20 ZSDM
    Content promotion          150          30 ZSDM
    Tutorial creation          500         100 ZSDM

4️⃣  ECONOMIC CONTRIBUTION (15% weight)
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    Activity                   Points      Tokens
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Stake 1K ZSDM               100          15 ZSDM/month
    Provide liquidity         1,000         150 ZSDM/month
    Platform fees paid           50           7 ZSDM
    Support creators            200          30 ZSDM
```

---

## MILESTONE TO TOKEN FLOW

```
╔════════════════════════════════════════════════════════════════════╗
║              FROM ACHIEVEMENT TO WALLET                            ║
╚════════════════════════════════════════════════════════════════════╝


EXAMPLE: NBA Oracle Market Settlement (Project Example)
═══════════════════════════════════════════════════════════════════

⏱️ TIME  │ STAGE                    │ WHAT HAPPENS
─────────┼──────────────────────────┼────────────────────────────────
00:00    │ 🎯 Event Trigger         │ NBA game closes + result finalized
         │                          │
00:01    │ 🤖 AI Detection          │ Validators detect event settlement
         │                          │ Query sports and pricing APIs
         │                          │ Verify cross-source consistency
         │                          │
00:02    │ ✅ Validation Complete   │ Confidence: 98%
         │                          │ Fraud check: PASSED
         │                          │ Ready for recording
         │                          │
00:03    │ ⛓️  On-Chain Recording   │ Calls ProjectOracleFeed.sol
         │                          │ recordOracleResult()
         │                          │ Creates immutable record
         │                          │
00:04    │ 📊 Score Calculation     │ Content pts: +100
         │                          │ Apply multipliers
         │                          │ Total contribution score
         │                          │
00:05    │ 💰 Token Minting         │ Base: 100 ZSDM
         │                          │ Consensus bonus: +30 ZSDM
         │                          │ Calls mint() function
         │                          │
00:06    │ ✅ COMPLETE              │ 130 ZSDM in your wallet!
         │                          │ Ready to use immediately
         │                          │ No gas fees paid by you


Total Time: ~6 minutes from achievement to tokens in wallet
```

---

## VALIDATION DISPUTE FLOW

```
╔════════════════════════════════════════════════════════════════════╗
║           WHAT IF VALIDATION IS WRONG?                             ║
╚════════════════════════════════════════════════════════════════════╝

Scenario: AI Validator Rejects Your Event/Price Submission
───────────────────────────────────────────────────────────────────

Step 1: FILE DISPUTE
┌──────────────────────────────────────────────────┐
│  You: "Event outcome was correct but no tokens minted" │
│  System: "Validation confidence was only 45%"          │
│  You: Submit provider proofs and signed evidence       │
└──────────────────┬───────────────────────────────┘
                   │
                   ▼
Step 2: ORACLE REVIEW (Manual)
┌──────────────────────────────────────────────────┐
│  Oracle Validator:                               │
│  ✓ Reviews your evidence                         │
│  ✓ Checks official data providers                │
│  ✓ Verifies timestamps                           │
│  ✓ Makes final decision                          │
└──────────────────┬───────────────────────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
        ▼                     ▼
    UPHELD                REJECTED
        │                     │
        ▼                     ▼
┌──────────────┐      ┌──────────────┐
│  ✅ YOU WIN  │      │  ❌ DENIED   │
│              │      │              │
│ • Tokens     │      │ • Small fee  │
│   minted     │      │   charged    │
│ • +10% bonus │      │ • Prevents   │
│   for wait   │      │   spam       │
└──────────────┘      └──────────────┘


Timeline: 48 hours maximum for dispute resolution
```

---

## SMART CONTRACT INTEGRATION MAP

```
╔════════════════════════════════════════════════════════════════════╗
║              HOW THE CONTRACTS WORK TOGETHER                       ║
╚════════════════════════════════════════════════════════════════════╝


                    [OFF-CHAIN]
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
   Social APIs      Sports APIs      Pricing APIs
        │                │                │
        └────────────────┼────────────────┘
                         │
                         ▼
              🤖 AI Validator Service
              (Monitors & Validates)
                         │
                         ▼
              ⚡ BASE VALIDATOR NODES
            (Consensus Layer - 21-100 nodes)
            • Each node verifies independently
            • Vote on validation results
            • Submit multi-sig approvals
                         │
                         │
        ━━━━━━━━━━━━━━━━━┿━━━━━━━━━━━━━━━━━
                         │
                    [ON-CHAIN]
                         │
                         ▼
        ┌────────────────────────────────┐
        │   ValidatorRegistry.sol        │
        │   (NEW - Base Validator Mgmt)  │
        │                                │
        │   • registerValidator()        │
        │   • stakeTokens()              │
        │   • stakeLPTokens()            │
        │   • submitVote()               │
        │   • getActiveValidators()      │
        │   • slashValidator()           │
        │   • distributeRewards()        │
        └────────────┬───────────────────┘
                     │
                     │ Validators approved
                     │
                     ▼
        ┌────────────────────────────────┐
        │   SocialMilestoneAdapter.sol   │
        │                                │
        │   • recordMilestone()          │
        │   • verifyMilestone()          │
        │   • getMilestone()             │
        │   • hasMilestone()             │
        │   • requireConsensus()  (NEW)  │
        └────────────┬───────────────────┘
                     │
                     │ Emits: MilestoneRecorded
                     │
                     ▼
        ┌────────────────────────────────┐
        │   ProofOfContribution.sol      │
        │   (Future deployment)          │
        │                                │
        │   • calculateScore()           │
        │   • getContribution()          │
        │   • updateWeights()            │
        └────────────┬───────────────────┘
                     │
                     │ Score calculated
                     │
                     ▼
        ┌────────────────────────────────┐
        │   BurnMintERC677.sol           │
        │   (Token Contract)             │
        │                                │
        │   • mint(to, amount, data)     │
        │   • transfer()                 │
        │   • burn()                     │
        └────────────┬───────────────────┘
                     │
                     ├─────────────────────────┐
                     │                         │
                     ▼                         ▼
            💰 Creator Wallet         ⚡ Validator Rewards
               (You get paid!)         (Validators get paid!)
                                      • 1% of minted tokens
                                      • Split among active nodes


Contract Addresses:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• BurnMintERC677: 0x2eEe2880F8bC24aeBad3B3c22Dd7541c7D846676
• ValidatorRegistry: [Pending deployment] (NEW)
• SocialMilestoneAdapter (YouTube-capable): [Pending deployment]
• ProofOfContribution: [Pending deployment]
```

---

## CREATOR JOURNEY MAP

```
╔════════════════════════════════════════════════════════════════════╗
║           YOUR PATH FROM ZERO TO EARNING                           ║
╚════════════════════════════════════════════════════════════════════╝


DAY 1: ONBOARDING
├─ Connect wallet (MetaMask/WalletConnect)
├─ Link YouTube channel
├─ Verify ownership
└─ Enable notifications ✓

     │
     ▼

DAY 1-30: BUILDING
├─ Upload videos regularly
├─ Grow subscriber base
├─ System tracks progress
└─ No action needed from you

     │
     ▼

DAY 30: FIRST MILESTONE! 🎉
├─ 100 subscribers reached
├─ AI validates (5 min)
├─ Recorded on-chain
├─ 20 ZSDM minted → your wallet
└─ Email: "You earned 20 ZSDM!"

     │
     ▼

DAY 60: MOMENTUM BUILDING
├─ 500 subscribers
├─ Consistency bonus: +10%
├─ 55 ZSDM minted
└─ Total earned: 75 ZSDM

     │
     ▼

DAY 90: ACCELERATING
├─ 1,000 subscribers
├─ High engagement bonus: +50%
├─ Community active: +20%
├─ 150 ZSDM minted
└─ Total earned: 225 ZSDM

     │
     ▼

DAY 180: ESTABLISHED CREATOR
├─ 5,000 subscribers
├─ Multiple bonuses stacking
├─ 750 ZSDM minted
└─ Total earned: 975 ZSDM

     │
     ▼

YEAR 1: SUCCESS! 🚀
├─ 10,000 subscribers
├─ Top creator tier
├─ 1,500 ZSDM minted
├─ Total earned: 2,475 ZSDM
└─ Also earning from views, videos, engagement...


Plus ongoing rewards for:
• Every new video
• View milestones
• Engagement metrics
• Community participation
• Referring other creators
```

---

## ECOSYSTEM INTERCONNECTION

```
╔════════════════════════════════════════════════════════════════════╗
║          HOW EVERYTHING CONNECTS IN THE ECOSYSTEM                  ║
╚════════════════════════════════════════════════════════════════════╝


                       DIAMONDZ SHADOW
                      ┌──────────────┐
                      │  ECOSYSTEM   │
                      └───────┬──────┘
                              │
            ┌─────────────────┼─────────────────┬─────────────────┐
            │                 │                 │                 │
            ▼                 ▼                 ▼                 ▼
      ┌──────────┐      ┌──────────┐     ┌──────────┐     ┌──────────┐
      │ CREATORS │      │   BASE   │     │VALIDATORS│     │ PLATFORM │
      │          │      │VALIDATORS│     │ (AI/Human)│    │          │
      └────┬─────┘      └────┬─────┘     └────┬─────┘     └────┬─────┘
           │                 │                 │                 │
           │                 │                 │                 │
    Creates content   Runs consensus    Validates work    Provides infra
    Earns tokens      Stakes/LP tokens  Earns fees        Earns revenue
           │                 │                 │                 │
           └────────┬────────┴────────┬────────┴─────────────────┘
                    │                 │
                    ▼                 ▼
              ┌──────────┐      ┌──────────┐
              │  TOKEN   │      │GOVERNANCE│
              │   ZSDM   │      │   DAO    │
              └────┬─────┘      └────┬─────┘
                   │                 │
                   │                 │
            Reward currency    Community votes
            Utility token      Protocol upgrades
            Staking asset      Validator voting
                   │                 │
                   └────────┬────────┘
                            │
                            ▼
                    ┌──────────────┐
                    │  SUSTAINABLE │
                    │  ECOSYSTEM   │
                    └──────────────┘


FLOWS BETWEEN COMPONENTS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Creators → Validators:
    Submit milestones for validation

Validators → Base Validators:
    Submit validation results for consensus

Base Validators → Creators:
    Approve or reject milestones (final decision)
    
Creators → Platform:
    Use infrastructure, pay fees
    
Platform → Creators:
    Provide tools, analytics, support
    
Base Validators → Platform:
    Run oracle infrastructure
    Form consensus layer
    Maintain network security
    
Platform → Base Validators:
    Pay validation fees (1% of mints)
    Provide RPC/API access
    Software updates
    
Projects → Base Validators:
    Stake 50K ZSDM or provide LP
    Run community nodes
    Earn validation rewards
    
Base Validators → Projects:
    Sustainable revenue stream
    Governance participation
    Community trust building
    
Token → All:
    Medium of exchange & rewards
    Staking asset for validators
    LP provision option
    
All → Governance:
    Vote on protocol changes
    Validator requirements
    Reward distributions
    
Governance → All:
    Implement community decisions
    Adjust consensus parameters
    Update fee structures
```

*Last Updated: 2025-10-10*
