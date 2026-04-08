# 5. DAO Governance

Shadow Peoples Vault is governed by a fully on-chain DAO using OpenZeppelin Governor with TimelockController.

---

## 5.1 Governance Contracts

| Contract | Address |
|----------|---------|
| vSDM (Voting SDM) | `0x05D8d99FEf3c93452e69b8a1d8B6B6241042F4d6` |
| Governor (Shadow DAO) | `0x4dA73496D52DD67C9CfD8d910126aF183b16CA38` |
| TimelockController | `0x733E190C9283CF3d03Df0CAf3DBb50a70847E3C4` |

---

## 5.2 vSDM Mechanics

vSDM is an ERC20Votes wrapper. Users call `wrap(amount)` to convert SDM → vSDM (1:1), `unwrap(amount)` for the reverse, and `delegate(address)` to activate voting power. vSDM is fully transferable.

---

## 5.3 Proposal Lifecycle

1. **Proposal Creation** — Any vSDM holder submits encoded contract calls
2. **Voting Delay** — ~1 day (7,200 L1 blocks; Arbitrum's block.number tracks Ethereum L1 at ~12s/block)
3. **Voting Period** — ~3 days (21,600 L1 blocks)
4. **Quorum Check** — Passes if `For > Against` AND `For + Abstain ≥ 9%` of total vSDM supply

> *Note: Quorum follows standard OpenZeppelin GovernorCountingSimple (`COUNTING_MODE: support=bravo&quorum=for,abstain`). Against votes are intentionally excluded from quorum, consistent with Compound Governor Bravo and all major DAOs using OZ Governor.*

5. **Queue** — Passed proposals enter TimelockController
6. **Timelock Delay** — 48 hours before execution
7. **Execution** — Anyone can trigger after delay

---

## 5.4 DAO vs Admin Security Separation

The vault enforces strict on-chain access control separation:

**DAO Can Control (`onlyGovernanceOrOwner`):**
- `setFees()` — withdrawal fee rates
- `setAllocation()` — basket/yield split ratio
- `setRevenueSplit()` — buyback vs treasury ratio
- `setProtocolYieldFee()` — yield take rate

**Admin Only (`onlyOwner` — Gnosis Safe 2-of-3):**
- `pause()` / `unpause()` — emergency response
- `setWhitelist()` / `setWhitelistEnabled()` — security gate
- `setSwapper()` / `setAdapter()` / `setSeeder()` — contract address changes
- `rescueToken()` — emergency fund recovery
- `transferOwnership()` — ownership transfer

This separation ensures that even if an attacker accumulates enough vSDM, they can only modify economic parameters and cannot drain funds, pause the vault, or change contract addresses.

---

## 5.5 Governance Transition Plan

- **Phase 1 (Current):** Multisig — Gnosis Safe 2-of-3 owns all contracts
- **Phase 2:** Hybrid — Safe transfers economic params to Timelock
- **Phase 3:** Full DAO — All ownership → Timelock, Safe keeps emergency cancel
- **Phase 4:** Autonomous — Safe renounces cancel role, fully decentralized
