# 15. Crabby Creator Ecosystem

CrabbyTV and its surrounding contracts form the **creator and entertainment layer** of Shadow Diamondz. Where ShadowVault, ShadowzDex, and the lending stack monetize capital, the Crabby stack monetizes *attention* — and routes the same fee flywheel (§9) underneath it. The layer is built from four cooperating pieces: the **CRABBY token**, **Crabby Social** (on-chain social protocol), **Crabs in a Barrel** (self-serve creator networks), and **CrabbyTV** (the consumer streaming front-end), all served by two Cloudflare rendering/scoring Workers.

---

## 15.1 CRABBY Token

| Parameter | Value |
|-----------|-------|
| Symbol | CRABBY |
| Canonical address | `0x05387b385be4D5038C755e7efA3D742f1b5B2bEB` (Arbitrum, UUPS proxy) |
| Total supply | 3,000,000,000 |
| Deprecated v1 | `0x33e3DdD8d9952DE9D8D005529F844c8d9c14f3Af` (1B — **do not wire**) |

CRABBY is the streaming-platform utility and social-staking token. The **v2 proxy is canonical**; the v1 contract is deprecated and retained only for historical reference. Always verify `totalSupply()` returns 3B before integrating. The supporting AMM infrastructure is unchanged:

| Contract | Address | Purpose |
|----------|---------|---------|
| CrabbyPoolV1 | `0x12470c8ce5e5CbBaF4367b65ee42Ee2E8Db86812` | WETH / PGOLD / wSOL tri-asset pool |
| CrabbyLPFarm | `0xf5ca0303211f18E5a896e6D1478865b5F94cFa27` | Stake CRABLP, earn CRABBY |
| CrabbyMultiZap | `0xCf5c4A9C90c198E3bAf04c4fe682608D40409Bb9` | Single-asset entry via 0x quote |

---

## 15.2 Crabby Social v2 — Engagement as On-Chain Capital

Crabby Social is a decentralized social protocol on Arbitrum One where **profiles are vaults, posts are markets, and the feed is a stake-weighted orderbook**. v1 (deployed 2026-05-20) is paused; **v2 is live** from block 25145518.

| Contract | Address | Role |
|----------|---------|------|
| CrabbySocialProfileV2 | `0xd37500E2eCd609b21d1332f09F660d79700dBe1d` | Tiered subscription profile NFTs (ERC4906 dynamic URI) |
| ProfileRenderer | `0xd5fF4DAE05CF8c4dF2a47BDB8bb0c3e431F8fA94` | On-chain SVG profile art |
| ProfileMarketplace | `0x582f878104c498d4ccf5bb114c6285b1DB08e4b7` | Profile-NFT resale, 60/30/10 split |
| CrabbyPostMarketV2 | `0x44bD5606F13832b2F142091d592F36Df667DD31C` | Post-as-market trading |
| CrabbyFeedBoostV2 | `0x21E9e040222502Fb210A53B953425EC3bCba2963` | Stake-weighted feed ranking |
| CommunityFactory | `0x68BbC8Aab46f8222563A20d180840df8E946966C` | Per-creator community token + curve |
| CommunityRouter | `0x905E1fA85e13d582943Db9333459DcFC5b2DD5B4` | Community fee splitter |
| CommunityLPVault | `0x7bF4b799597043A8fC0a7B8466ed6828391B9f93` | Permanently locked LP from graduated curves |

**Mechanics:**

- **Subscription tiers** — Bronze (50 CRABBY), Silver (250), Gold (1000). 5% routes directly to the creator; the remainder is locked in-contract.
- **Profile NFT transfers** are gated to `ProfileMarketplace` only, splitting **60% seller / 30% treasury / 10% original creator** so creators keep a perpetual cut of profile resales.
- **Per-creator community token** (`cc#id`, ERC-20) trades on a virtual-reserve constant-product `CommunityCurve` — subscriber-gated for the first 20%, anti-dump tax, and **auto-graduates to a ShadowzDex LP** at 5k CRABBY reserve + 100 holders + an engagement threshold. The graduated LP is locked forever in `CommunityLPVault`.
- **Post-trade fee split** — 10 bps total: Creator 5 / Treasury 2 / Repost 1 / Community 2; sell spread 10%.
- **Feed boost** — 25% of a boost deepens the creator's community curve; 75% follows the stake / decay / slash model. Curve is closed post-migration, so the social split routes **70% to the profile owner, not the curve reserve**.
- **Community LP `collectFees`** splits V3 swap fees **30% treasury / 70% creator**.

---

## 15.3 Crabby Social Tiers & the Off-Chain Renderer

Two Cloudflare Workers serve the social layer's dynamic state:

**`nft.crabbytv.com` — Profile renderer.** Serves ERC-721 metadata and animated SVG from live chain + subgraph state. Routes: `GET /profile/<id>` (metadata JSON), `/profile/<id>/image` (animated SVG), `/profile/<id>/tier`. Tier formula:

| Tier | Threshold |
|------|-----------|
| **Spark** | any minted profile |
| **Current** | `subs ≥ 10` AND `engagement ≥ 100` |
| **WAVS** | `subs ≥ 50` AND `uniqueHolders ≥ 25` AND `engagement ≥ 1000` |

**`wavs.crabbytv.com` — WAVS scorer.** A 10-minute cron Worker that computes engagement scores from the Crabby Social subgraph and writes `CrabbyFeedBoostV2.setMultipliers(...)` as `WAVS_ROLE` (batched ≤ 50 profiles/run). This closes the loop: real engagement → on-chain feed multipliers → ranking. Both Workers read the Goldsky `crabby-social/v2` subgraph and Arbitrum RPC.

---

## 15.4 Crabs in a Barrel — Self-Serve Creator Networks

**Crabs in a Barrel** (the `community-creator-suite` app) lets any creator launch a fully branded "barrel" — their own community network — without exposing the underlying CrabbyTV infrastructure to their audience. It is a TanStack Start app (React 19, Vite, shadcn-ui, Tailwind) on Cloudflare Workers, backed by Supabase, with LiveKit (instant browser broadcast, ~2–3s connect) and Livepeer (RTMP/OBS) for streaming and Thirdweb/wagmi for the optional web3 surface.

**Capabilities:**

- **Onboarding → provision → channel lineup** — self-serve "Launch Your Barrel" flow, dynamic branded channel pages.
- **Catalog** — Livepeer-backed video library with play/delete management.
- **Promos** — short pre-roll clips (4–15s), AI-generated via the `crabbytv-promo` pipeline (Gemini Vision auto-tag → Seedance 2.0 image-to-video → `promos` bucket → `network_promos` row with cost tracking). Promos can be attached to a channel as the featured pre-roll, or published as standalone NFT content.
- **Multi-station radio** — synchronized-playhead audio stations.
- **CrabbyTV branding** — watermark/end-card overlays on catalog videos, with a CrabbyTV billboard end-card.
- **NFT Streams** — attach live or catalog content to launchpad Position NFTs with holder-gating (see §17).
- **Mail Studio** — branded mailing-list templates (Premiere Drop, Live Now, Weekly Recap, Music Release).

> **Data topology.** The shared app database is Supabase project `ivg` (`ivggvlshjtiindcsrznc`); `rvwaavjt` is the personal/co-host project; the Lovable echo app (`wou…`) is separate. The client DB pointers are never repointed.

---

## 15.5 CrabbyTV — Consumer Front-End

CrabbyTV ([crabbytv.com](https://crabbytv.com)) is the consumer-facing streaming destination: a live-streaming platform with virtual gift/tipping, a co-host multi-video grid, and FAST channel distribution (Roku, Fire TV, Apple TV). The **AI co-host** (Beyond Presence avatar + Claude + 11Labs) can join livestreams under a per-minute USDC pre-deposit model routed to the Arbitrum Safe.

On-chain, `CrabbyTVMVP.sol` provides creator milestone validation and progression: Milestone Units → Creator Credits (10:1) → Reputation Badges (100:1) → Wavz Score, auto-verified at ≥95% oracle confidence.

The Crabby creator stack and CrabbyTV are the consumer entry points to the launchpad (§16) and streaming NFTs (§17): a creator runs a barrel, launches a presale through the launchpad, and attaches holder-gated streams to the resulting Position NFTs — all settling fees into the same treasury that powers the SDM buyback (§9).
