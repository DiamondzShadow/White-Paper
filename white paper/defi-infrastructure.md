# 4. Diamond Basket Vault (DBV) & Yield Infrastructure

The **Diamond Basket Vault V3** is an ERC-4626 compliant multi-asset vault on Arbitrum. Users deposit USDC and receive DBV shares representing a diversified basket: SDM 20%, WBTC 20%, ARB 15%, SOL 15%, USDC 30% (Aave). DBV is the yield-bearing baseline the ecosystem points at for users who want one-click diversified exposure without picking a single V15 pool.

| Contract | Address | Role |
|----------|---------|------|
| DBV Vault V3 | `0xFc2B1DFdeE79139356C3deae983f74FC2aB96855` | ERC-4626, 6 decimal shares, dead-share protected |
| DBV Adapter V4 | `0x23b65deEbBe383c7F9425C9bE048EC360D568214` | Basket manager, 0x-based rebalance |
| zDi0 (DiamondzChain mirror) | `0xafa689849631A9420ab8C514EE96E66af205eC4d` | 6-dec bridged share |

DBV uses virtual offset `1e6` and dead shares to prevent the classic ERC-4626 share-inflation exploit. DBV shares mint a `BasketReceipt` financial NFT (§6.1) — listable on the EcosystemMarketplace and collateralizable in LendingPool v1.4 like any other ShadowVault position.

---

## 4.1 Yield Adapter Stack (Arbitrum)

`YieldBridgeRelay` (`0x8B04A9385485a79d1A11D829F6BFceC21d463789`) routes DBV's 30% yield slice across a small, audited adapter set:

| Adapter | Address | Allocation | Strategy |
|---------|---------|-----------|----------|
| AaveLoopAdapter | `0xF011Bc5B0893279b72AF4D1c933856D94a3433a9` | 70% | Aave V3 E-Mode recursive (stablecoin-to-stablecoin, 97% LTV) |
| LidoStETHAdapter | `0x2d1371c8A9b607012e95cFf57bB20705ce88c9A5` | 20% | Lido stETH liquid staking |
| FlashArbAdapter | `0x0aa891Ee89Ee927b051fe92A5B7a2e6849695f5A` | 5% | Aave V3 flash-loan arb |
| Withdrawal buffer | YieldBridgeRelay | 5% | USDC reserve for instant withdrawals |

Every adapter exposes `rescueToken(token, to, amount)` — a rule enforced ecosystem-wide after a $5 residual got stuck in a broken Aave adapter. Without `rescueToken` the admin Safe has no escape path other than a full vault migration.

### Risk bounds on the Aave loop

| Parameter | Value |
|-----------|-------|
| Max loops | 3 |
| Effective leverage | ~3.3× |
| E-Mode LTV | 97% |
| E-Mode liquidation threshold | 98% |
| Health-factor monitor interval | 30s |
| Deleveraging trigger | HF < 1.5 |
| Deleveraging target | HF > 2.0 |
| Emergency unwind | Safe, instant |

E-Mode is stablecoin-to-stablecoin only: both legs are USDC-denominated, so mark-to-market volatility does not move the health factor. The keeper can unwind all three loops in a single transaction on the admin Safe.

---

## 4.2 SDM Liquidity Infrastructure (Arbitrum)

| Contract | Address | Role |
|----------|---------|------|
| SDM/USDC Uni V3 pool | `0x25a7f80d191086B77cEB5Bb368C3e71F875Bb4AE` | 1% fee tier, canonical SDM price |
| SDM LP Farm | `0x0CFa723ef4980C6D5eA218EF4C9552B83379Ee94` | 1M SDM over 90 days to LPs |
| VestedLPFarm | `0x31eEaE675Cd489568d0764CEd8757C934c3a29Eb` | 250K SDM, vesting schedule |
| SDMLPZapV2 | `0x6e5286F9A264d5CED77BD5C9C0540490889be7e9` | TWAP-oracle zap-in, 50% USDC → treasury |
| DODO DPP (DBV/USDC) | `0x781dfce2518b9840e8f0165333bdff3170ef1f9c` | Seeder V2 buyback venue |
| FlashLoanArb | `0x7d81D8ea1791AB668cD92990f29213D8D426F888` | Aave V3 flash-loan alpha |
| LPFeeGateway | `0xbb99…8044B` | 0.03% of every V2/V3 LP deposit → Arb Safe |

The 1% fee tier on the Uni V3 pool matches SDM's volatility and long-tail liquidity profile. `SDMLPZapV2` uses a **TWAP oracle** (not spot) on the single-asset-in path to prevent sandwich attacks on zap deposits.

---

## 4.3 Beyond V15 — Extended Yield Surfaces

V15 is the primary deposit-and-earn product, but the ecosystem also runs:

- **SweepV2 + Compound (Arb)** — v2 `0xEc1815…0B11`, comp `0xDC5078…585e`
- **SweepV2 + Aave (Polygon)** — v2 `0x41F033…8D62`, aave `0xa40941…bBdb`
- **LendingPool v1.4 → AaveV3Sink** — liquidated collateral earns yield while the sweeper skims to cover accrued interest
- **HyperRemoteMirror** — cross-chain value mirror that powers the Hyper ↔ Arb NFT wrapper value push

These are supporting infrastructure for the main V15 / ShadowzDex / Marketplace + Lending surfaces. See §6 for how the lending stack uses AaveV3Sink, and §11.3 for how Chainlink CCIP + LayerZero keep the cross-chain mirrors honest.
