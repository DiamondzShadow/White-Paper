# 4. DiamondzChain Bridge & zwTokens

The DiamondzChain Bridge enables cross-chain asset transfer between Arbitrum One and DiamondzChain (Chain ID 7791) using a lock-mint-burn-unlock mechanism secured by 2-of-3 validator consensus.

---

## 4.1 Bridge Architecture

| Contract | Network | Address |
|----------|---------|---------|
| BridgeLock | Arbitrum | `0x7b26203DdCc59c6605c814ef5cB3acfcBf1F3Ab3` |
| BridgeFeeDAO | Arbitrum | `0xF9d7B346eEc8CbeE12B51727f9F7B7C9E2a7F047` |
| BridgeMint | DiamondzChain | `0x3d9F35cB176e808E95F8fc665E34407114748967` |
| BridgeValidatorV2 | DiamondzChain | `0xC239A8647F00EE01587659AA5B169aA21A60779d` |

---

## 4.2 Bridge Flow

**Arbitrum → DiamondzChain:** User calls `lock(token, amount, destination)` on BridgeLock. Three validator nodes detect the lock event, reach 2-of-3 consensus via BridgeValidatorV2, which mints equivalent zwTokens to the user on DiamondzChain.

**DiamondzChain → Arbitrum:** User calls `bridgeBurn(amount, arbRecipient)` on the zwToken. Validators detect the burn, reach consensus, and call `unlock()` on BridgeLock to release original tokens on Arbitrum.

---

## 4.3 Bridge Fee Structure

| Amount (USD) | Fee | Burn Back Fee |
|-------------|-----|---------------|
| $1–$10 | Flat $0.42 | 0.60% |
| $10–$100 | Flat $0.30 | 0.60% |
| $100+ | 0.30% | 0.60% |

**SDM Holder Discount:** 50% fee reduction for wallets holding 9,000+ SDM.

**Fee Split:** 50% treasury, 26% validators, 14% zwSDM pool, 10% SDM pool.

---

## 4.4 Wrapped zwTokens (DiamondzChain)

Six wrapped tokens provide native representations of Arbitrum assets:

| zwToken | DZX Address | Decimals | Arbitrum Source |
|---------|------------|----------|-----------------|
| zwUSDC | `0x07005e3C06eB59A61ceF073342a5209026518CD4` | 6 | USDC `0xaf88d065...8e5831` |
| zwBTC | `0xE665f92a018827e79CDC3b64dB799B4Ba5Da70c7` | 8 | WBTC `0x2f2a2543...C5B0f` |
| zwSDM | `0x0b8244AdCDBCbC63Dfff3dc6e5037d4A6C553069` | 18 | SDM `0x602b869e...3394` |
| zwPGOLD | `0x75F95a08304BFfAa83952C22be2Ec8dcEfD36b2d` | 18 | PGOLD `0x3e76BB02...4F91` |
| zwARB | `0x9BACD2CE1FcF456C3F57EED3915Aa98F66A72849` | 18 | ARB `0x912CE591...6548` |
| zwETH | `0x0E43A32913e1659E7c11eeCa15992Ef8993BFd1B` | 18 | WETH `0x82aF4944...fBab1` |

Each zwToken uses OZ v4 ERC20Upgradeable + AccessControl + UUPS. `BRIDGE_ROLE` is held by BridgeValidatorV2; `DEFAULT_ADMIN_ROLE` by Gnosis Safe.

---

## 4.5 zDi0 — Vault Share Bridge Token

zDi0 (`0xafa689849631A9420ab8C514EE96E66af205eC4d` on DiamondzChain, 6 decimals) is the bridged representation of DBV vault shares. Users bridge DBV shares from Arbitrum to DiamondzChain and receive zDi0 at 1:1, inheriting the vault share price.
