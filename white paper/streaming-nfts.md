# 17. Streaming NFTs — Content-Bearing Position NFTs

A **Streaming NFT** (or *NFT-Stream*) turns a launchpad Position NFT into a content key. The same on-chain position that earns yield and serves as collateral (§16) also gates access to a creator's media — public clips anyone can watch, or holder-only premieres revealed only after on-chain ownership and tier are proven. The sale contract is decoupled from the content: the same presale can serve any creator's streams, and content is attached or rotated without redeploying anything on-chain. Shadow Reborn is the first sale wired this way.

---

## 17.1 The Idea

Position NFTs carry an on-chain **tier** (0 = Bronze, 1 = Silver, 2 = Gold) and a USD value. Streaming NFTs map that tier onto content visibility:

- **Public streams** — embedded inline on the watch page for anyone, no wallet required.
- **Holder-gated streams** — the playback ID is withheld from the page and revealed only after a wallet signature is verified against `ownerOf` *and* the holder's on-chain tier meets the stream's `min_tier`.
- **Scheduled premieres** — optional countdown to a `premiere_date`.

Three content kinds are supported: **live** (Livepeer playback), **upload**, and **link** (a private external URL). This makes a presale position double as a season pass, a premiere ticket, or a backstage key — without ever moving the gating logic off-chain.

---

## 17.2 On-Chain Renderer

Each presale points at a per-sale renderer via `setTokenRenderer` (`OPERATOR_ROLE`, reversible). The renderer is intentionally minimal — it reads the Position (`tier`, `usdValue`, `founder`), draws an on-chain SVG card, and injects watch deep-links into the metadata:

```
tokenURI → base64 JSON {
  image:         <on-chain SVG>,
  external_url:  https://watch.barrels.crabbytv.com/<sale>/<tokenId>,
  animation_url: https://watch.barrels.crabbytv.com/<sale>/<tokenId>
}
```

| Sale | Renderer v2 | Notes |
|------|-------------|-------|
| Shadow Reborn (SDM) | `0x8Ab05fb2eBABF1Db7e9695752B26843d890D0E50` | live on Arbitrum |
| — legacy v1 | `0xAfF1d7963a32ED1449580DC8eb877806455d428e` | swappable back via `setTokenRenderer` |

The renderer stays under the 24 KB limit by holding no content itself; it only constructs the JSON and the Worker URL. A marketplace listing therefore always shows current tier/value, and the "watch" link resolves through the preview Worker.

---

## 17.3 The Watch Worker (`sr-preview`)

`sr-preview` is a stateless, multi-sale Cloudflare Worker (custom domain `watch.barrels.crabbytv.com`, `.workers.dev` fallback) serving the watch experience for any Arbitrum presale.

| Route | Behavior |
|-------|----------|
| `GET /` | Gallery / landing |
| `GET /<tokenId>` | Watch page for the default sale |
| `GET /<sale>/<tokenId>` | Watch page for any presale (address-normalized, checksummed) |
| `POST /api/unlock` | Holder-gated unlock: signature → `ownerOf` + tier check → reveal |

On a watch request the Worker calls `readCard()` (fetch `tokenURI`, decode, extract tier) and `fetchStreams()` (Supabase REST, service-role) to pull active streams. Public streams embed a Livepeer player inline; holder-gated streams hold back the `playbackId` and reveal it only through `POST /api/unlock` after recovering the signer and confirming on-chain ownership + tier. It reads the Arbitrum RPC and the shared `ivg` Supabase project; the service-role key is a Worker secret, never exposed to the browser.

---

## 17.4 Data Model & Access Control

Two RLS-gated Supabase tables back the feature in project `ivg`:

- **`nft_sale_links`** — maps a sale contract (lowercased) to a verified creator account 1:1. A creator proves control by signing with the wallet that holds `DEFAULT_ADMIN_ROLE` on the sale; the server recovers the signer and verifies `hasRole(...)` on-chain before inserting the link. Public read, owner write.
- **`nft_streams`** — the content rows: `kind` (`live`/`upload`/`link`), `livepeer_playback_id` / `external_url`, `visibility` (`public`/`holders`), `min_tier` (0–2), `token_id` (NULL = whole sale, set = a single position), `is_premiere` / `premiere_date`, `is_active`.

RLS is the security gate: **anon read returns only `is_active AND visibility = 'public'` rows**; gated rows are never sent to the browser. Only the service-role Worker reads gated rows, and only after it has proven ownership on-chain. There is no path by which a non-holder receives a gated playback ID.

---

## 17.5 Creator Flow & Reusability

Creators manage streams from the Crabs-in-a-Barrel dashboard (§15.4):

1. **Verify** — sign with the sale's admin wallet; server recovers + checks `hasRole` on-chain, inserts the `nft_sale_links` row.
2. **Attach** — add streams (kind, visibility, optional premiere, `min_tier`), optionally scoped to a single `token_id`.
3. **Watch** — the Worker handles the rest; nothing else is deployed.

Onboarding a *new* sale is: deploy a renderer, call `setTokenRenderer`, sign to link, attach streams. Because the Worker is multi-sale and the renderer is per-sale-but-stateless, the streaming layer scales across every future launchpad presale with no per-sale Worker deploy. This is the bridge between the launchpad (§16) and the Crabby creator stack (§15): a presale position becomes a living, gated content surface.
