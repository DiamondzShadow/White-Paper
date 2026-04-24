# Shadow Diamondz — Ecosystem Whitepaper

**Whitepaper v4.0 · April 2026 · [Shadow Diamondz Game + Movie Development, Inc.](https://diamondzshadow.info)**

This repository is the source of truth for the Shadow Diamondz ecosystem whitepaper. The rendered book is published via GitBook; markdown sources live in [`white paper/`](./white%20paper) and are synced on push to `main`.

---

## Read the whitepaper

Start here: **[`white paper/README.md`](./white%20paper/README.md)** — the Abstract, section index, and version metadata.

### v4.0 sections (current)

| # | Section |
|---|---------|
| 2 | [SDM Token & Multi-Token Economy](./white%20paper/sdm-token.md) |
| 3 | [ShadowVault V15](./white%20paper/shadow-peoples-vault.md) |
| 4 | [DiamondzChain Bridge & zwTokens](./white%20paper/diamondz-bridge.md) |
| 4.1–4.3 | [Diamond Basket Vault & Yield Infrastructure](./white%20paper/defi-infrastructure.md) |
| 5 | [DAO Governance](./white%20paper/dao-governance.md) |
| 6 | [Financial NFTs & NFT-Backed Lending](./white%20paper/financial-nfts.md) |
| 7 | [ShadowzDex — The Intent DEX](./white%20paper/shadowzdex.md) |
| 8–10 | [Ecosystem Platforms & Unified Fee Flywheel](./white%20paper/ecosystem.md) |
| 11 | [Protocol Integrations — 0x, Uniswap, Chainlink](./white%20paper/protocol-integrations.md) |
| 12 | [Multi-Chain Expansion](./white%20paper/multi-chain-expansion.md) |
| 13–14 | [Security & Infrastructure](./white%20paper/security-and-infrastructure.md) |

Legacy context (pre-v3) is retained under [`white paper/archive/`](./white%20paper/archive).

---

## What's in v4.0

- **ShadowVault V15** live on Arbitrum (Morpho / GMX / Aave / Fluid), Polygon (Aave / Gains / Aave / C4C), and HyperEVM (HyperSkin / ShadowPass). 9 vaults, 12/3/3 fee schedule, live-value financial NFTs.
- **ShadowzDex** — intent-based DEX at [dex.diamondz.one](https://dex.diamondz.one) with an attestor-signed 11-field intent, venue adapters for 0x / Uniswap V2–V3 / Sushi V2 / V15, and cross-chain settlement over Chainlink CCIP (Arb ↔ Polygon ↔ Base).
- **EcosystemMarketplace + LendingPool v1.4** — NFT marketplace with royalty router, NFT-backed lending with yield-to-loan auto-repay, cross-chain position wrappers via CCIP and LayerZero.
- **Unified fee flywheel** — every protocol fee routes to a single revenue router: 50% SDM buyback via DODO + Uniswap V3 LP seeding, 50% Arbitrum treasury Safe.
- **Protocol integrations deep-dive** — how we use 0x Swap API v2, Uniswap V2/V3 pools + LPFeeGateway, and Chainlink CCIP + Data Feeds.

---

## Contributing

Markdown edits to `white paper/*.md` are reviewed via pull request. GitBook renders from `main` on merge. Section numbering is stable — when adding a section, append rather than renumber unless a majority restructure is warranted.

## Resources

- **Website**: [diamondzshadow.info](https://diamondzshadow.info)
- **DEX**: [dex.diamondz.one](https://dex.diamondz.one)
- **CrabbyTV**: [crabbytv.com](https://crabbytv.com)
- **DZX Exchange**: [zdiamondex.store](https://zdiamondex.store)
- **GitHub**: [github.com/DiamondzShadow](https://github.com/DiamondzShadow)
- **Discord**: [discord.gg/diamondzshadow](https://discord.gg/diamondzshadow)
- **Twitter**: [@DiamondShadoM](https://twitter.com/DiamondShadoM)
- **Email**: [development@diamondzshadow.com](mailto:development@diamondzshadow.com)

---

## License

MIT — see [LICENSE](./LICENSE).

*© 2025–2026 Shadow Diamondz Game + Movie Development, Inc.*
