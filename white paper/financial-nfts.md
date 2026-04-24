# 6. Financial NFTs & NFT-Backed Lending

Every ShadowVault deposit is a financial NFT — a live-valued ERC-721 whose price is the underlying vault position. That single design decision turns every user deposit into a composable primitive: it can be listed on a marketplace, used as collateral in an NFT-backed loan, bridged across chains, or sold with the position in a single OpenSea click. This section documents the NFT classes, the marketplace, the lending stack, and the cross-chain mirrors.

---

## 6.1 NFT Classes

ShadowVault ships three NFT classes. The class is determined by the vault, not by the deposit, so a user with positions in Pool A, the DBV basket, and Pool E holds three NFTs from three contracts.

| Class | Minted by | What it represents | Live value |
|-------|-----------|--------------------|-----------|
| `YieldReceipt` | Single-strategy V15 vaults (Pool A–D, Pool F) | posId → underlying adapter balance + accrued yield | `NFTValuer.priceOf(tokenId)` |
| `BasketReceipt` | Diamond Basket Vault (DBV, ERC-4626) | DBV shares | share price × balance |
| `ShadowPass` | HyperEVM Pool E (HyperSkin) | HLP equity + Safe-gated traits | `ShadowPassValuer` |

The ERC-721 `tokenId` is synced to the vault `posId` via `syncNextTokenId()`. The vault never calls `nft.mint()` outside `deposit()` — this is an ecosystem-wide rule (feedback_no_direct_nft_mint) because direct mints break the tokenId ↔ posId 1:1 and render the NFT untradable.

On-chain SVG art encodes the basket composition, tier, deposit amount, and current USD value; the metadata re-renders on every block via `tokenURI`, so a marketplace listing always shows the up-to-date portfolio value (feedback_nft_live_value).

---

## 6.2 EcosystemMarketplace

The marketplace lets any ShadowVault NFT be listed for sale. It is composed of three contracts (all live and verified on Arbitrum and Polygon, 2026-04-20):

| Contract | Role |
|----------|------|
| `EcosystemMarketplace` | Listing / bid / accept flow, USDC-denominated |
| `DiggerRegistry` | Whitelist of NFT contracts eligible to list (anti-spam, anti-spoofing) |
| `RoyaltyRouter` | Per-collection royalty split — default 2.5% to Arb Safe |

**Diamondz is "digger #1"** — the first registered lister — and the V15 Pool A–D NFTs are registered as collections under that digger on both Arbitrum and Polygon. New diggers pay a 0.1 USDC registration bond (flat, not % of listing) to deter spam.

The royalty router is the marketplace's contribution to the fee flywheel: 2.5% of every secondary sale is routed to the Arbitrum treasury, which is where the SDM buyback originates (§9).

---

## 6.3 NFTValuer v2 — Live Oracle

`NFTValuer v2` (Arb: `0x3BBCb09B…60B8`) is the oracle that tells the rest of the stack what a ShadowVault NFT is worth *right now*. It reads the underlying vault's position and computes a USD value using Chainlink price feeds (§11.3) with staleness guards — stale feeds revert rather than return an old price, because a stale valuation is the single highest-risk input to any NFT-backed loan.

v2 added the `VAULT_MIRROR` role, which lets wrapped positions from other chains (Polygon / HyperEVM) be valued on Arbitrum as if they were native. Keepers (see §6.6) push the latest value onto the wrapper.

---

## 6.4 LendingPool v1.4 — Borrow Against Your NFT

`LendingPool v1.4` (Arb: `0x4BA07796…f4aF`, verified) is the NFT-backed lending protocol. A user deposits a ShadowVault NFT as collateral and borrows up to a conservative LTV of the NFT's `NFTValuer` USD value.

Earlier revisions were drained and paused — v1.2 had a valuer rewiring bug — so **v1.3 introduced the NFTValuer dependency** and v1.4 added **yield-to-loan auto-repay**: the user can toggle a slider that routes a configurable % of the NFT's accrued yield to repay the loan balance. The loan self-amortizes from the vault yield; the user gets a credit line secured by a yielding position instead of an idle one.

| Parameter | Value |
|-----------|-------|
| Lending asset | USDC |
| Collateral | Whitelisted ShadowVault NFTs (YieldReceipt, BasketReceipt, ShadowPass-wrapped) |
| Max LTV | 50% (conservative; tightened after v1.2 drain) |
| Valuer | `NFTValuer v2` (VAULT_MIRROR aware) |
| Auto-repay | Opt-in slider, 0–100% of accrued yield |
| Liquidation | Yield-based sink (AaveV3Sink) on default |

The sink sells the collateral at `NFTValuer` price to the `AaveV3Sink` pool, which deposits the resulting USDC into Aave V3. A `SweepController` skims the Aave yield to cover accrued interest + any bad debt. Lending interest splits are documented in §9.

---

## 6.5 Cross-Chain NFT Bridging

ShadowVault NFTs are cross-chain native. Two bridges are live:

### 6.5.1 Polygon ↔ Arbitrum — via Chainlink CCIP

| Contract | Chain | Address | Role |
|----------|-------|---------|------|
| `PolygonNFTLocker` | Polygon | `0xd67ACb…65aD` | Locks Polygon V15 NFT, emits CCIP |
| `ArbPositionWrapper` | Arb | `0x43e91f…4BA0` | Mints wrapped position |

The Polygon-side v1 locker (`0x8f74dc…EFFA`) shipped with a bad-LINK wiring and was retired; v2 (`0xd67ACb…`) is canonical. The Arb wrapper is registered in the `DiggerRegistry` and priced by `NFTValuer.VAULT_MIRROR`, which means a wrapped Polygon NFT is indistinguishable from a native Arb NFT for marketplace listing and lending purposes.

### 6.5.2 HyperEVM ↔ Arbitrum — via LayerZero

| Contract | Chain | Address | Role |
|----------|-------|---------|------|
| `HyperPositionLocker` | Hyper | `0xFC8f588b…7381` | Locks Pool E / ShadowPass NFT |
| `HyperPositionWrapper` | Arb | `0x4228b8E9…fd68` (verified) | Mints wrapped position |
| `ShadowPassValuer` | Arb | `0x27980Da1…C702` | Prices wrapped ShadowPass NFTs |

DVN configuration was read-back-verified on both send and receive libraries on both chains (2R + 2O) at go-live. Pool E HyperSkin and ShadowPass are both bridgeable — a user in the Hyper ecosystem can collateralize a ShadowPass on Arbitrum without ever touching HyperCore directly.

---

## 6.6 Keepers — Value Push

Two PM2-managed keeper services push live value onto the wrappers so an NFT's stated USD value stays fresh on whichever chain it currently lives on:

- `ccip-value-push` — Poly ↔ Arb, uses Chainlink CCIP
- `lz-value-push` — Hyper ↔ Arb, uses LayerZero

Both sign updates to `NFTValuer.setVaultMirror(tokenId, usd)` on a periodic cadence and on threshold events. The keepers run alongside `sweep-v2-arb` / `sweep-v2-poly` (which harvest vault yield) and share the same GCP VM cluster (§13).

---

## 6.7 What Financial NFTs Unlock

- **List for sale** — `EcosystemMarketplace`, USDC-denominated, royalty to Safe
- **Borrow against** — `LendingPool v1.4`, up to 50% LTV, auto-repay from yield
- **Bridge** — CCIP (Poly ↔ Arb) or LayerZero (Hyper ↔ Arb) while keeping live value
- **Trade on OpenSea** — ERC-721 standard, on-chain SVG, royalty enforced
- **Compose** — the wrapped form is a standard ERC-721 on Arb, so any future Arb protocol can integrate ShadowVault positions without a custom adapter

The NFT is the position. Every upgrade to the lending pool, the marketplace, the valuer, or the bridge automatically lifts the entire installed base of ShadowVault deposits — no migration required on the user side.
