# 13. Security

- **Smart contracts:** OZ `AccessControl` + per-chain Gnosis Safe (no `Ownable` on production contracts), `Pausable`, `ReentrancyGuard`, ERC-4626 dead-share protection, same-block cooldown on vault mutations.
- **Admin separation (§3.7 / §5.4):** DAO can move economic parameters only — fees, ratios, multipliers. Pause, whitelist, adapter-address changes, and `rescueToken` are Safe-only. A hostile vSDM majority cannot drain funds.
- **Per-chain Safes:** one Safe per chain per purpose. A contract's admin Safe on Arbitrum is *not* the same as the contract's Safe on Polygon, even when the contract address matches. Cross-chain Safe assumptions are the single most common source of admin-brick risk; we always cross-check.
- **Bridge security:** 2-of-3 validator consensus on `BridgeValidatorV2`; validator keys in separate operator environments. Chainlink CCIP (§11.3) for SDM + ShadowzDex settlement; LayerZero for HyperEVM NFT bridge with DVN config read-back-verified on both libraries on both chains.
- **Attestor (ShadowzDex):** hosted at `attestor.diamondz.one`. Four launch-blocker bugs (taker spoofing / minOut drop / oracle bypass / chain-ID string) were patched before go-live. The 11-field intent router re-checks `taker`, `minOut`, and Chainlink `oracle` staleness on-chain — attestor signatures alone do not suffice.
- **Verified, deterministic deploys:** CREATE3 used for same-address multichain deploys (zSDM at `0xfc8D5874…d00470` on Arb + Poly + Base + HyperEVM). Contracts verified on Arbiscan / Polygonscan / Basescan / HypurrScan and open source.
- **Keepers:** PM2-managed services on GCP VMs (30s health loop). Self-hosted rather than Chainlink Automation for current-scale cost reasons; every keeper is idempotent and Automation-portable.
- **Key handling:** deployer / treasury keys live only on user-controlled VMs or GCP env — never in a repo, IDE chat, or CI secret. Read-only data API keys (OpenSea / Uniblock / Alchemy) sit server-side behind `attestor.diamondz.one` so they never ship to the browser.
- **Pre-deploy checklist:** verify `SAFE_ADMIN` via `cast code` + `getThreshold` + cross-check the per-chain Safe registry before any deploy that hands over admin roles. This was added after a 2026-04-21 admin-brick during a prior ShadowzDex deploy.

---

# 14. Infrastructure

| Item | Value |
|------|-------|
| DiamondzChain RPC | `rpc-mainnet.diamondz.baby` |
| DiamondzChain ID | 7791 |
| DiamondzChain Explorer | `diamondz.tryethernal.com` |
| **Arb Safe** (SDM admin, buyback destination) | confirmed 2026-04-20 |
| **Polygon Safe** | confirmed 2026-04-20 |
| **Base Safe** | confirmed 2026-04-20 |
| **HyperEVM Safe** | confirmed 2026-04-20 |
| Treasury (legacy, v2.x era) | `0x6052C6559eD5e5CbE74Ac0D42205Ad4A1CFBEd43` |
| Deployer | `0xC5D133296E17BA25DF0409a6C31607bf3B78e3e3` |
| 0x AllowanceHolder (Arb) | `0x0000000000001ff3684f28c67538d4d072c22734` |
| DEX gateway | [dex.diamondz.one](https://dex.diamondz.one) |
| Attestor (ShadowzDex) | `attestor.diamondz.one` |
| CCIP mesh | Arbitrum ↔ Polygon ↔ Base (SDM + NFT value + DEX settlement) |
| LayerZero bridge | HyperEVM ↔ Arbitrum (ShadowPass, Pool E NFTs) |

Per-chain Safe addresses are maintained in an internal reference document and rotated via the per-chain Safe owners, not by contract redeploy. Contract `DEFAULT_ADMIN_ROLE` holders are always the current per-chain Safe.

---

*Built by Shadow Diamondz Game + Movie Development, Inc.*
*© 2026. All rights reserved.*
