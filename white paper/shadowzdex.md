# 7. ShadowzDex — The Intent DEX

ShadowzDex is the ecosystem-native trading layer: an **intent-based DEX** where users sign an order and an off-chain **attestor** picks the best venue to fill it. The on-chain surface is a single router with pluggable venue adapters — 0x, Uniswap V2/V3, Sushi V2, and the V15 vaults themselves. Cross-chain intents settle over Chainlink **CCIP** across an Arb ↔ Polygon ↔ Base mesh.

ShadowzDex went live on Arbitrum in April 2026; a $1 USDC Arb ↔ Base round-trip was executed end-to-end on mainnet on 2026-04-21. The public gateway is at [dex.diamondz.one](https://dex.diamondz.one).

---

## 7.1 Architecture

```
User ─┐
      ▼
   Gateway UI (dex.diamondz.one)
      ▼                           ┌── 0x venue  ──▶  0x Swap API v2 (AllowanceHolder)
   Attestor ──── signs intent ────┼── SushiV2   ──▶  SushiV2Adapter
   (attestor.diamondz.one)        ├── UniV2/V3  ──▶  LPDepositCard(V2/V3)
      ▼                           ├── V15       ──▶  ShadowVaultV15 adapter
   IntentRouter (11-field)        └── CCIP      ──▶  Arb ↔ Poly ↔ Base
```

| Contract | Address | Role |
|----------|---------|------|
| IntentRouter | `0xE80a…D1Ee` (Arb) | 11-field intent verify + dispatch to venue |
| IntentRouter (retired) | `0x49B9…7817` | Frozen 2026-04-24, kept read-only |
| SushiV2Adapter | `0x6F31…D2cf` (Arb, verified) | USDC ↔ FBAC one-click via Sushi V2 |
| LPFeeGateway | `0xbb99…8044B` (Arb) | 0.03% surcharge on V2/V3 LP deposits → Safe |
| Attestor | `attestor.diamondz.one` | Signs 11-field intents, `/opensea/*` proxy baked in |

All five venue adapters were redeployed for the 11-field migration (2026-04-24) so each adapter can `import IVenueAdapter` cleanly — the inline-struct hack is gone.

---

## 7.2 The 11-Field Intent

An intent is a signed struct that carries everything the attestor needs to dispatch a fill:

1. `taker` — msg.sender of the eventual execution
2. `tokenIn` / `amountIn`
3. `tokenOut` / `minOut`
4. `venue` — venue ID (0x, Sushi, V15, …)
5. `chainIn` / `chainOut` — numeric chain IDs (not strings)
6. `oracle` — Chainlink feed used for the minOut guard
7. `expiry` — unix seconds
8. `salt` — uniqueness nonce
9. `attestorSig` — EIP-712 signature from the attestor key

The router re-checks `taker`, `minOut`, and the Chainlink `oracle` staleness on-chain before dispatching — these are four bugs the attestor shipped pre-launch (taker spoofing / minOut drop / oracle bypass / chain-ID string) and that were patched before go-live. The chain-guard and the Chainlink staleness check are now part of the router, not the attestor.

---

## 7.3 Venue Adapters

### 7.3.1 0x — aggregator venue

The 0x adapter forwards `amountIn` of `tokenIn` to the 0x Swap API v2 via the **AllowanceHolder** flow (`0x0000000000001ff3684f28c67538d4d072c22734` on Arb) and enforces `minOut` post-swap. 0x is the default venue for any pair without a direct on-chain pool. See §11.1 for the integration details.

### 7.3.2 SushiV2Adapter — on-chain direct venue

For whitelisted pairs (e.g. USDC ↔ FBAC) the adapter performs a single `swapExactTokensForTokens` against Sushi V2 on Arb. `setVenue(SUSHI_V2, adapter)` was the correct wiring path on `IntentRouter` — not `setAdapter`, a subtle distinction that tripped the first integration.

### 7.3.3 Uniswap V2/V3 paste-box (on /pools)

Users paste any Sushi V2/V3 or Uniswap V2/V3 pool address into the Gateway `/pools` page. A factory-whitelisted detector identifies the pool class and mounts either `LPDepositCard` (V2) or `LPDepositCardV3` (V3 full-range mint). 9 unit tests cover the detect-and-mount path.

LP deposits route through the **LPFeeGateway** (`0xbb99…8044B`), which pulls **0.03%** of the user's deposit into the Arbitrum treasury Safe before minting the LP position. This is the single cleanest fee hook in the system — it fires on every V2 and V3 deposit, including Uniswap and Sushi.

### 7.3.4 V15 vaults as a venue

A user intent `tokenOut = pool-A-share` fills through the `ShadowVaultV15` venue adapter, minting a V15 position NFT directly from the DEX surface. This is the legacy-free replacement for the broken `V15PoolAdapter` routing — the DEX never calls the old adapter; it dispatches to `vault.deposit()` via the direct-deposit path documented in §3.2.

---

## 7.4 Cross-Chain via CCIP

Cross-chain intents settle over a three-way Chainlink CCIP mesh: **Arbitrum ↔ Polygon ↔ Base**. The $1 USDC Arb → Base → Arb round-trip was executed end-to-end on mainnet on 2026-04-21 — the first proven cross-chain intent settlement in the ecosystem.

CCIP is used because it is what the canonical SDM token uses (Base SDM + pool `0x8cecbac8…a502` went live the same week), which means a single CCIP-token-pool topology covers SDM bridging, NFT value pushes, and cross-chain intent settlement. §11.3 covers the CCIP topology in detail.

---

## 7.5 Pool Inspector — Nebula Chat

Every pool listed in the gateway has a "Pool Inspector" chat tab wired to **thirdweb Nebula**. Users ask natural-language questions ("what's this pool's TVL trend?", "who's the biggest LP?") and Nebula responds with live on-chain data. One upstream quirk to note: `chain_ids` must be passed as strings to Nebula, not integers — a silent failure otherwise.

---

## 7.6 Marketplace & Banners

The `/marketplace` surface (live since 2026-04-23, gateway `main` `3ccc659`) lists NFT collections via a server-side proxy at `attestor.diamondz.one/opensea/*`, which holds the OpenSea API key out of the client. `/pools` and `/earn` carry TVL / APR / recent-activity banners driven by Uniblock + GeckoTerminal data (see §11 for the Uniblock gotchas — `walletAddress` vs `walletAddr`, the CG-mapping coverage cliff, etc.).

---

## 7.7 Fee-Tier Spec (pending FeeVault)

The intent fee schedule is locked but not yet deployed:

| SDM holding | Intent fee |
|-------------|-----------|
| 0 | 20 bps |
| ≥ 9,000 SDM | 10 bps (50% discount, matches the Bridge tier) |
| ≥ 90,000 SDM | 5 bps |

The `FeeVault` + `SwapIntent` extension + keeper are the next scheduled ShadowzDex drop. Until then, the DEX runs fee-free on intent orders; the LPFeeGateway 0.03% is the only live fee on the DEX surface.
