# 12. Multi-Chain Expansion

The ecosystem is production-live on **four EVM chains** and has a Solana mirror staged on devnet. Every chain except Solana is wired into the Chainlink CCIP mesh or a LayerZero adapter; fees collected anywhere in the ecosystem route to the Arbitrum treasury Safe for a single, unfragmented SDM buyback (see §9.4).

---

## 12.1 Arbitrum One — Canonical Home

Arbitrum is the ecosystem's home chain. Everything originates here: SDM, the V15 Pool A–D vaults (Morpho / GMX / Aave / Fluid), the ShadowzDex IntentRouter, the EcosystemMarketplace + LendingPool v1.4, the LPFeeGateway, the DBV basket vault, the DiamondzChain Bridge, the canonical Gnosis Safe.

SDM: `0x602b869eEf1C9F0487F31776bad8Af3C4A173394`. All addresses elsewhere in the paper refer to the Arbitrum deployment unless explicitly marked.

---

## 12.2 Polygon — LIVE

The full stack is ported and live on Polygon:

| Contract | Status |
|----------|--------|
| V15 Pool A–D (Aave / Gains / Aave / C4C) | LIVE, whitelist open |
| Real C4C V4 strategy | `0x8Fd0195…EBE9` |
| DiggerRegistry + RoyaltyRouter + EcosystemMarketplace | LIVE, verified |
| NFTValuer + LendingPool | LIVE, verified |
| PolygonNFTLocker | `0xd67ACb…65aD` (v1 retired, bad-LINK) |
| SDM via CCIP | `0xDd5C…` (canonical, owner-gated) |
| zSDM | `0xfc8D5874…d00470` (CREATE3 same address across chains) |

Diamondz is digger #1 on Polygon with Pool A–D NFTs registered. Polygon gas is ~$0.08 at current POL price (2026-04); we do not treat Polygon cost as a barrier to user transactions.

---

## 12.3 Base — LIVE

Base was activated in April 2026 to complete the three-way CCIP mesh:

| Contract | Status |
|----------|--------|
| SDM on Base | `0x64F5a84b…02f0` LIVE |
| SDM CCIP pool | `0x8cecbac8…a502` LIVE |
| zSDM | `0xfc8D5874…d00470` (same CREATE3 address) |
| ShadowzDex cross-chain settlement | LIVE, $1 USDC round-trip verified |

Base is a settlement chain today, not (yet) a vault-deployment chain. The V15 Base port is next in the multi-chain queue after the HyperEVM operator hand-over.

---

## 12.4 HyperEVM — LIVE (Pool E + F)

HyperEVM hosts the two exotic vaults:

| Contract | Status |
|----------|--------|
| Pool E HyperSkin (HLP) | LIVE, trait layer wired |
| Pool F ShadowPass | LIVE, trader EOA wired |
| HyperPositionLocker | `0xFC8f588b…7381` |
| ShadowPassValuer (on Arb) | `0x27980Da1…C702` |
| zSDM | `0xfc8D5874…d00470` |
| LayerZero send/recv DVN config | Verified 2R+2O on both libraries, both chains |
| HyperPositionWrapper (on Arb) | `0x4228b8E9…fd68`, verified, registered in DiggerRegistry |

Pool E tracks HyperLiquid HLP equity directly via the HLPAdapterHC. The v1 spot/perp bug that made the initial $5 seed never register as HLP equity was fixed in v2 — the $5 seed now lands in HLP equity in ~5 seconds.

HyperCore hidden costs to budget: 1 USDC HyperCore activation, 1 USDC per `spotSend`, and a user-signed `sendAsset` to the system address will **burn** funds. Our contracts never use that path.

---

## 12.5 DiamondzChain (L3, ID 7791) — LIVE

The Arbitrum-Orbit AnyTrust L3 that hosts the zwToken bridge mirror:

| Contract | Status |
|----------|--------|
| BridgeMint | `0x3d9F35cB…748967` |
| BridgeValidatorV2 | `0xC239A8647F…60779d` |
| 6 zwTokens (zwUSDC, zwBTC, zwSDM, zwPGOLD, zwARB, zwETH) | LIVE |
| zDi0 (bridged DBV share) | `0xafa689849631A9420ab8C514EE96E66af205eC4d`, 6 decimals |

RPC `rpc-mainnet.diamondz.baby`, explorer `diamondz.tryethernal.com`.

---

## 12.6 Solana — Phase 2 (devnet deployed, mainnet staged)

Two Anchor programs for a V15 port on Solana:

- ShadowVault Solana — mirrors the V15 deposit/withdraw shape
- Solana → Arb mirror NFT — user gets a position on Solana, a mirrored NFT on Arb for the marketplace + lending integration

Both programs are **LIVE on devnet** and compile clean on Anchor 1.0 (repo: `github.com/DiamondzShadow/shadow-vault-solana`). Exact mainnet deployment cost measured at **3.376 SOL** (fund 3.5 SOL). Phase-2 pools intended for mainnet:

| Basket | Strategy |
|--------|----------|
| Kamino USDC | Kamino K-Lend supply |
| Jupiter JLP | Jupiter Perps LP (CPI integration built) |
| Sanctum INF + SOL basket | Sanctum INF LST + SOL |
| Maple syrupUSDC | Maple Finance syrupUSDC |

**Drift is excluded** — the April 2026 exploit removed it from consideration.

MVP decisions locked: internal audit (not external), deployer-admin for beta, Phantom + Backpack wallets, CCIP-bridged NFTs (Solana → Arb mirror for OpenSea listing). Metaplex Core is the NFT standard.

---

## 12.7 Cross-Chain Summary Table

| Chain | V15 | ShadowzDex | Marketplace + Lending | SDM token | zSDM |
|-------|-----|------------|----------------------|-----------|------|
| Arbitrum | ✅ A–D | ✅ | ✅ | canonical | ✅ |
| Polygon | ✅ A–D | — | ✅ | ✅ via CCIP | ✅ |
| Base | — | ✅ settlement | — | ✅ via CCIP | ✅ |
| HyperEVM | ✅ E + F | — | ✅ via wrapper | staged (white-glove) | ✅ |
| DiamondzChain | — | — | — | zwSDM mirror | — |
| Solana | devnet | — | via CCIP mirror | — | — |

---

## 12.8 Future Chains

The V15 multichain queue has **Base → Sonic → BNB → Berachain** in order. Base is a same-day port because the Arb V15 code compiles unchanged; the other three are budgeted against ecosystem governance priorities. DZX Exchange on DiamondzChain (hybrid DEX with AMM pools + bonding curves) and Robinhood Chain (BigUp stock vault) are separate tracks driven by product, not by V15 replication.
