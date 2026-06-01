# 18. ShadowzPerps — AI-Co-Piloted Perpetuals

ShadowzPerps is the ecosystem's perpetuals venue: a **Hyperliquid-only** perps front-end at [perps.diamondz.one](https://perps.diamondz.one) with a Claude-powered AI co-pilot, a deterministic auto-management keeper, and a public leaderboard. Orders route to Hyperliquid with the ecosystem's builder code attached; every fee — builder rebates, AI chat, and trade execution — sweeps to the Arbitrum treasury Safe and feeds the same buyback flywheel (§9).

---

## 18.1 Why HL-Only

A GMX V2 adapter was deployed to Arbitrum and then deliberately left dormant (scrapped 2026-05-03) because it could not reach parity with Hyperliquid's market coverage and UX. ShadowzPerps therefore trades exclusively on Hyperliquid: orders are signed client-side (EIP-712) and posted to the HL API with the ecosystem **builder code** (`0xC5D133296E17BA25DF0409a6C31607bf3B78e3e3`) attached, earning a **0.3 bps builder fee** per filled trade. No on-chain adapter is required for the HL path. The dormant on-chain contracts (FeeVault, QuoteVerifier, IntentRouter, GMXV2Adapter) remain deployed but unused on Arbitrum.

---

## 18.2 AI Co-Pilot

The co-pilot is a Claude agent fronted by an x402-paywalled gateway (`shadowz-perps-agent-gateway`). Requests settle gaslessly via EIP-3009 (`transferWithAuthorization`) to the Base Safe, which periodically bridges to the Arbitrum Safe — no pre-funding required.

| Action | Price |
|--------|-------|
| Chat (`POST /chat`, SSE stream) | $0.10 / request |
| Intent create (planned) | $0.25 |
| Intent fill (planned) | $1.00 |
| Agent activate (autonomous tier) | $0.50 |

Phase A (live) is read-only: the agent's tools are `get_hl_markets`, `get_hl_market`, `get_hl_positions`, and `get_hl_recent_fills`. The default model is `claude-haiku-4-5` for cost, with `claude-sonnet-4-6` available for nuance. The write path (signed order submission) and autonomous execution are gated behind later phases.

---

## 18.3 Deterministic Auto-Management Keeper

Autonomous management is **rule-based, not LLM-driven** — the trade decisions are deterministic TypeScript, while only the chat surface uses the model. The keeper (`shadowz-perps-keeper`) runs eight pm2 workers on a dedicated VM:

| Worker | Function |
|--------|----------|
| `intent-watcher` | FSM for managed positions: pre-TP1 → hard-stop guard → post-TP1 trailing stop; limit orders on price/time/trailing triggers |
| `auto-trader` | Dispatches `/internal/autonomous_tick` (every 300s) for users with `agent_autonomy.tier` ∈ {partial, full} and `kill_switch=false` |
| `hl-rebate-tracker` | Polls HL builder fees credited to the builder wallet; writes daily totals |
| `funding-snapshotter` | Hourly funding-rate snapshots per market |
| `hl-treasury-sweeper` | When HL credits ≥ $25, bridges USDC to Arbitrum and forwards to the Arb Safe |
| `sentiment-scorer` | Market/social sentiment (Gemini Vision + LLM) feeding autonomous decisions |
| `fear-greed-snapshotter` | Periodic Fear & Greed index snapshots |
| `perf-fee-sweeper` | Daily performance-fee batch sweep to Arb Safe |

A **liquidation guard** auto-closes a position when the mark consumes 80% of the entry-to-liquidation distance (configurable). Autonomous execution runs in `DRY_RUN` in the current phase; live execution via signed HL orders is the next gate.

---

## 18.4 Leaderboard

`perps-leaderboard-worker` is a Cloudflare Worker (5-minute cron) that ranks traders by closed PnL over 24h / 7d / 30d windows, sourcing Hyperliquid fills from the Allium API. Per trader it reports 30d notional, fill count, maker/taker split, paid fees, current HL fee tier, and HYPE-staking ROI projections.

| Endpoint | Returns |
|----------|---------|
| `GET /api/leaderboard?window=7d` | ranked trader list |
| `GET /api/fees?address=0x…` | fee-tier analysis + HYPE staking ROI |
| `GET /api/spot-stats?chain=arb` | ShadowzDex spot volume (Goldsky subgraph) |

> **Attribution note.** Hyperliquid fills attribute to the **owner address**, not the agent key — leaderboard and rebate queries key on `agent_autonomy.user_address`, never on the agent wallet.

---

## 18.5 Fee Routing

All ShadowzPerps revenue converges on the Arbitrum treasury Safe `0x18b2b2ce7d05Bfe0883Ff874ba0C536A89D07363`:

- **HL builder fees** (0.3 bps/trade) accrue to the builder wallet's HL account and are swept to the Arb Safe by `hl-treasury-sweeper` past a $25 threshold.
- **AI chat / intent fees** settle via x402 to the Base Safe, then bridge to Arbitrum.
- **DEX-agent trade fees** (companion service): DCA $0.10/run, limit fill 5 bps (floor $0.05), debited from prepaid USDC credits, routed to the Arb Safe.

From there they join the unified flywheel (§9): 50% executes the SDM buyback, 50% holds in treasury.
