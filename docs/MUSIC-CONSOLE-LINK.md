# Link to Sovereign Music Console

**Music repo:** `C:\Users\RH\Downloads\sandbox-os\../sovereign-music-console`  
**OS notes repo:** `C:\Users\RH\Downloads\sandbox-os`

## Division of labor

| Concern | Where it lives |
|---------|----------------|
| Shippable Music app, APK, tier34 server code | `sovereign-music-console` |
| OS vision, chronicle, phases, marketplace idea | `sandbox-os` (this repo) |
| Future shared identity / station SDK | TBD — likely `sandbox-sdk` extracted later |

Do **not** mix OS manifesto docs into the music repo unless you want release noise. Cross-link from each README.

## What Music already proves for the OS

| OS concept | Music implementation |
|------------|----------------------|
| Station | Whole app = Music station |
| Sandbox Server | `tier34-server/` |
| Locker | `lockerStorage.ts`, vault IndexedDB |
| Identity / signing | `tasteSigning.ts`, taste manifests |
| Device sync | `deviceSecretSync.ts` → `/api/device/secrets` |
| Federation sketch | `docs/federated-taste.md`, `/api/taste/share` |
| Connect (devices) | `/peer-sync` WebSocket |
| Builder | Scaffold in docs; record-player addon pattern |
| Infrastructure scaffold | `src-tauri/src/infrastructure/` (identity, event bus, runtime) |

## Server features relevant to OS social / marketplace

```
GET/PUT  /api/device/secrets     — cross-device keys (extend for social prefs)
POST     /api/taste/share        — signed public payloads (template for listings)
GET      /api/taste/:id
WS       /peer-sync              — multi-device session (not friend federation yet)
GET/POST /api/social/outbox      — v0 local household posts / shares (shipped)
GET      /api/social/threads…    — v0 local DMs (plaintext; not E2E yet)
GET/POST /api/marketplace/listings — v0 local listings (shipped)
POST     /api/social/inbox/pull  — federation pull (501 / not implemented)
```

**Shipped (household / local):** outbox CRUD, threads, marketplace listings, share.  
**Not shipped:** server-to-server federation pull, signature verification, E2E message crypto, follows sync to tier34.  
See also Pass 2 launcher audit: `docs/audit/launcher-analysis.md`.

## When to extract code from Music

Extract when **two stations** need the same module:

1. `sandbox-identity` — keys, sign, verify  
2. `sandbox-server-client` — tier34 API  
3. `sandbox-locker-core` — blob store abstraction  
4. `sandbox-station-host` — WASM or native station loader  

Until then, Music can move fast; OS repo tracks **protocols and dates** without blocking releases.

## Multi-root workspace (optional)

Open both folders in Cursor:

- `C:\Users\RH\Downloads\sovereign-music-console`
- `C:\Users\RH\Downloads\sandbox-os`

Music for shipping; `sandbox-os` for north star and chronicle updates after each design session.
