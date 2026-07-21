# Marketplace station

**Last updated:** 2026-07-07  
**Status:** Idea / architecture — not implemented

## Concept

A **Vinted / eBay–class station** built on what already exists on every phone and PC:

- **Storage (locker)** — photos, descriptions, optional video  
- **Sandbox Server** — list, sync, federate public catalog  
- **Identity (keys)** — seller/buyer reputation tied to cryptographic ID, not Facebook login  
- **Overlay** — buyers reach *your* node, not a warehouse in Virginia  

**Founder framing:** Most planetary infrastructure is already there (devices, internet, cameras, storage). The shift is **priority**: freedom and direct exchange, not platform extraction.

## How it differs from eBay/Vinted

| Incumbent | Sandbox Marketplace |
|-----------|---------------------|
| Central database of all listings | Federated: each seller’s server (or published subset) |
| Platform fees & ads | Configurable; default story = peer-to-peer, no engagement algorithm |
| Account = email + phone harvest | Account = key; share only what you publish |
| Trust = stars + chargebacks | Trust = signed history + optional escrow in Vault station |
| Must be online to browse catalog | Cached discovery; Builder can ship station offline |

## Data model (sketch)

```
Listing {
  id, sellerKeyId, title, description, price, currency,
  mediaRefs: [lockerBlobId...],
  locationHint?,  // optional, coarse — privacy tradeoff
  visibility: public | friends | unlisted,
  signature
}
```

- **mediaRefs** point into **locker** blobs (same storage Music uses for album art / files).  
- **Public listings** replicated to seller’s Sandbox Server outbox.  
- **Discovery:** client aggregates `GET /api/marketplace/outbox` from subscribed peers (friends, local co-op, search index you run).

## Payments (Vault station — later)

Not required for marketplace v0.1.

| Stage | Mechanism |
|-------|-----------|
| v0 | “Message seller” / arrange cash-in-person |
| v0.5 | Signed IOU / community ledger on server |
| v1 | Crypto rail (Lightning, stablecoin, etc.) in OS vault |
| v2 | Escrow smart contract or multisig between keys |

Legal note: “without banks” is a **technical** goal; **fiat and regulation** may still apply in many countries. OS should not promise lawlessness — promise **user custody** and **minimal intermediaries**.

## Federation & privacy

- Seller chooses **what** is public (title, blur photos until request).  
- No global “spy feed” of all purchases — unlike centralized marketplaces.  
- Optional **local index** (your server crawls friends only).  
- Spam: rate limits + web-of-trust (follow graph), not opaque ML bans.

## Phase placement

| Phase | Marketplace scope |
|-------|---------------------|
| 1 | Skip — focus identity + music + social |
| 2 | v0 listings on own server; trade with trusted friends |
| 3 | Federated search, Vault payments, reputation portable across nodes |

## Reuse from Music console

| Existing piece | Marketplace use |
|----------------|-----------------|
| Locker / IndexedDB blobs | Product images, attachments |
| tier34 blob storage | Sync listings media |
| Taste / identity signing | Sign listings & seller profile |
| Artist images / metadata patterns | Listing cards UI |
| Device secret sync | Same keys across sell phone and desktop |

Implementation stays in a **new station** (or `sandbox-marketplace` repo later); Music repo only shares protocols/SDK when extracted.

## Open design choices

1. Categories taxonomy — fixed vs user tags?  
2. Shipping — out of scope v0 or integrate postal APIs optionally?  
3. Disputes — community arbitration vs no central arbiter?  
4. Moderation — block list only vs shared blocklists between friends?
