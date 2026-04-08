# 12. Security

- **Smart Contracts:** Ownable2Step, Pausable, ReentrancyGuard, dead shares (ERC-4626 inflation prevention), same-block cooldown
- **Access Control:** 2-of-3 Gnosis Safe multisig (`0x2674bB72aC5dD7BDBFb9b342cE43Ea84A3d90A6F`). DAO governance limited to economic parameters only
- **Bridge Security:** 2-of-3 validator consensus. BridgeValidatorV2 enforces consensus before minting. Validator keys in separate environments
- **Operational:** Keeper bots on GCP VMs with 30-second monitoring. 0x API with approved router whitelist. Chainlink price feeds
- **All core contracts verified on Arbiscan and open source**

---

# 13. Infrastructure

| Item | Value |
|------|-------|
| DiamondzChain RPC | `rpc-mainnet.diamondz.baby` |
| Chain ID | 7791 |
| Explorer | `diamondz.tryethernal.com` |
| Gnosis Safe | `0x2674bB72aC5dD7BDBFb9b342cE43Ea84A3d90A6F` |
| Treasury | `0x6052C6559eD5e5CbE74Ac0D42205Ad4A1CFBEd43` |
| Deployer | `0xC5D133296E17BA25DF0409a6C31607bf3B78e3e3` |
| 0x Router | `0x0000000000001ff3684f28c67538d4d072c22734` |

---

*Built by Shadow Diamondz Game + Movie Development, Inc.*
*© 2026. All rights reserved.*
