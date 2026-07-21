# Sandbox Conduit — link to Sandbox OS

**Project path:** `C:\Users\RH\Downloads\sandbox-conduit (1)`  
**package.json name:** `sandbox-builder`  
**Dev server:** port **5174** (Express + Vite)  
**Last reviewed:** 2026-07-07

Conduit is the **Builder / creative station pack** — mostly built, parallel to Music, not inside `sovereign-music-console`.

---

## What Conduit is

Multi-station web/desktop app for **creating** things (compile apps, media, research) — not for playing your locker (that’s Music).

| Station | Purpose |
|---------|---------|
| **Horizon** | Launcher / home for all stations |
| **Tide** | Private browser |
| **Ocean** | Scholar search + research vault (RAG) |
| **Sandstone** | Planning, templates, guided pages |
| **Sand** | AI compile → VFS projects, packaging, golden path |
| **Reef** | Media production (timeline, TTS, export) |
| **Shore** | Audio brand kit |

**Docs to read in Conduit repo:**

- `docs/sandbox-architecture.md` — naming map  
- `docs/tier34-connection.md` — how Conduit talks to Music’s tier34  
- `docs/sovereign-local.md` — local LLM on desktop  
- `docs/THE_HARBOR_DEPLOY.md` — hosted deploy  

---

## Scale (approximate)

| Metric | Value |
|--------|-------|
| `src/**/*.{ts,tsx}` | ~608 files |
| `server/tenant/*.ts` | ~40 modules |
| Largest files | `App.tsx`, `TheSand.tsx`, `StationLayouts.tsx`, `sandstoneTemplates.ts` |
| E2E | 13 Playwright specs |
| Android | **No** — desktop Tauri + web only |

---

## What Conduit gives the OS

### Reuse now (high value)

| Component | Path | OS use |
|-----------|------|--------|
| **Multi-station shell** | `src/utils/stationRegistry.ts`, `AppHorizon.tsx`, `useAppNavigation.ts` | OS launcher pattern — register Music + Builder + future Marketplace |
| **Horizon launcher** | `src/components/app/AppHorizon.tsx` | “All stations” home screen |
| **Sand compile pipeline** | `TheSand.tsx`, `server/tenant/vfs.ts`, `managedCompile.ts`, `browserCompile.ts` | **Builder station** — offline templates, package ZIP/desktop |
| **Sandstone templates** | `sandstoneTemplates.ts`, `Sandstone.tsx` | Station scaffolds in minutes (booking-desk, etc.) |
| **Golden path UX** | `goldenPathProgress.ts`, `GoldenPathRail.tsx` | Onboarding pipeline across stations |
| **Ecosystem / tier34 client** | `ecosystemConnection.ts`, `tier34Client.ts`, `EcosystemServerPanel.tsx` | Shared localStorage keys with Music — extend for real Feed/locker |
| **Desktop identity** | `src-tauri/src/identity.rs`, `identityBridge.ts` | Ed25519 fingerprint — same pattern as Music |
| **LAN peer discovery** | `src-tauri/src/mdns.rs`, `discoverSandboxPeers` | Future: find friend nodes on LAN |
| **Encrypted API vault** | `server/tenant/keyVault.ts` | Secrets on **your** server, not Google |
| **Sovereign local LLM** | `src-tauri/src/inference.rs`, `sovereignLocalInference.ts` | Offline AI for Builder without cloud |
| **Harbor deploy** | `scripts/harbor-*.mjs` | Self-hosted or staging deploy of Builder |

### Reuse later (medium)

| Component | Notes |
|-----------|--------|
| **Reef / Shore** | Media station patterns for future creative tools |
| **Ocean** | Research station; RAG vault pattern for OS knowledge |
| **Stripe + entitlements** | If OS needs hosted Builder SaaS — not for sovereign-only mode |
| **Clerk auth** | Optional cloud tenants — OS 0.1 should stay keys-first per [DECISIONS.md](./DECISIONS.md) D-010 |

### Do not duplicate from Conduit

| Item | Where it already lives |
|------|------------------------|
| **tier34 server** | `sovereign-music-console/tier34-server/` |
| **Music locker / playback** | `sovereign-music-console/src/lockerStorage.ts`, playback pipeline |
| **Feed station UI** | Music `FeedView.tsx` |
| **Android / PWA music** | Music repo only |

---

## Honest gaps (Conduit v1)

From `docs/tier34-connection.md`:

| Feature | Status in Conduit |
|---------|-------------------|
| tier34 health probe | Wired |
| Feed browsing | **Not wired** — use Music |
| Locker blob sync | **Not wired** — health badge only |
| Spawn tier34 from Tauri | **Disabled** — run Music repo’s tier34 |

**mDNS peers** discover other **Conduit UI** instances — not yet a global federation mesh.

---

## Target three-piece architecture

```
                    ┌─────────────────────┐
                    │   sandbox-os        │
                    │   (docs + os-core)  │
                    └──────────┬──────────┘
                               │
           ┌───────────────────┼───────────────────┐
           ▼                   ▼                   ▼
   sovereign-music-console   sandbox-conduit    (future stations)
   Station: Music            Station: Builder   Marketplace, Vault…
   tier34 :3001              UI server :5174
           │                   │
           └─────────┬─────────┘
                     ▼
              tier34 Sandbox Server
              locker · feed · acquire · connect
```

**Pragmatic next step:** Extract `packages/os-core` from Conduit shell + shared `identityBridge` / `ecosystemConnection` → Music registers as station `music`, Conduit keeps seven creative stations.

---

## Overlap warnings (same name, different code)

| File name | Music | Conduit |
|-----------|-------|---------|
| `sandboxLayer3.tsx` | Full music OS shell (~7k lines) | Builder React context (~300 lines) |
| `sandboxLayer1.ts` | Playback + locker | Builder store re-export |
| `sandboxServerBridge.ts` | Spawns **tier34 :3001** | Spawns **UI sidecar :5174** |

Do not merge blindly — **rename or namespace** when extracting `os-core`.

---

## Related docs

- [MUSIC-CONSOLE-LINK.md](./MUSIC-CONSOLE-LINK.md)  
- [DECISIONS.md](./DECISIONS.md) — D-002, D-003, D-013  
- [PHASES.md](./PHASES.md)  
- Music: `docs/CHRONICLE.md`  
- Conduit: (consider adding `docs/CHRONICLE.md` there too)
