# 6. Diamond Basket Vault (DBV)

The Diamond Basket Vault V3 is an ERC-4626 compliant vault at `0xFc2B1DFdeE79139356C3deae983f74FC2aB96855` on Arbitrum. Users deposit USDC and receive DBV shares representing a diversified basket: SDM 20%, wBTC 20%, ARB 15%, SOL 15%, USDC 30% (Aave).

DBV uses 6 decimal shares with virtual offset 1e6 and dead shares to prevent the ERC-4626 inflation exploit. Adapter V4: `0x23b65deEbBe383c7F9425C9bE048EC360D568214`. Bridgeable to zDi0 on DiamondzChain.

---

# 7. Yield Infrastructure

## 7.1 Shadow DeFi Yield Stack (Arbitrum)

YieldBridgeRelay (`0x8B04A9385485a79d1A11D829F6BFceC21d463789`) manages a diversified yield stack:

| Adapter | Address | Allocation | Strategy |
|---------|---------|-----------|----------|
| AaveLoopAdapter | `0xF011Bc5B0893279b72AF4D1c933856D94a3433a9` | 70% | Aave V3 E-Mode recursive lending |
| LidoStETHAdapter | `0x2d1371c8A9b607012e95cFf57bB20705ce88c9A5` | 20% | Lido stETH liquid staking |
| FlashArbAdapter | `0x0aa891Ee89Ee927b051fe92A5B7a2e6849695f5A` | 5% | Aave V3 flash loan arbitrage |
| Withdrawal Buffer | YieldBridgeRelay | 5% | USDC reserve for instant withdrawals |

---

## 7.2 SDM Liquidity Infrastructure

- **SDM/USDC Uni V3 Pool:** `0x25a7f80d191086B77cEB5Bb368C3e71F875Bb4AE` (1% fee, $0.01–$0.10)
- **SDM LP Farm:** `0x0CFa723ef4980C6D5eA218EF4C9552B83379Ee94` (1M SDM over 90 days)
- **SDMLPZapV2:** `0x6e5286F9A264d5CED77BD5C9C0540490889be7e9` (TWAP oracle, 50% USDC to treasury)
- **DODO DPP (DBV/USDC):** `0x781dfce2518b9840e8f0165333bdff3170ef1f9c`
- **VestedLPFarm:** `0x31eEaE675Cd489568d0764CEd8757C934c3a29Eb` (250K SDM, vesting schedule)
- **FlashLoanArb:** `0x7d81D8ea1791AB668cD92990f29213D8D426F888`
