# Sandbox OS — Vision

**Last updated:** 2026-07-07

## One sentence

An operating environment where **your devices talk to your server and your friends’ servers**, with Music, Social, Marketplace, Vault, and Governance built in — **sovereign by default**, not rented from platforms that monetize attention and data.

## Problem

- Windows / Android / iOS centralize identity, apps, and data in corporations.  
- “Free” services fund surveillance and lock-in.  
- Banking, social, and media are separate silos with different logins and export policies.  
- People who want privacy must become sysadmins — too high a bar.

## Answer

| Layer | What it is |
|-------|------------|
| **Kernel / base** | Start with **Linux** (drivers, power, security LTS). Custom kernel only if Linux fails a hard requirement later. |
| **Sandbox shell** | Unified UI, settings, identity, station launcher |
| **Stations** | Music (shipped), Social, **Marketplace**, Vault (payments), Vote (governance) — first-party + Builder |
| **Sandbox Server** | Per-user or per-household node; sync, relay, federated outbox |
| **Builder** | Offline station packages in minutes; signed, no App Store required |
| **Overlay** | Self-hosted reachability (Headscale/Nebula/etc.) so nodes work worldwide without Google relay |

## Non-goals (for early versions)

- Replacing every app on day one  
- Beating Spotify’s catalog scale  
- Unregulated “no banks ever” in every jurisdiction on v0.1  
- National election infrastructure before community-scale voting works  

## Design tenets

1. **Keys = you** — Ed25519 identity; optional display name; no email required for core use.  
2. **Publish, don’t leak** — Server holds what you choose to share; E2E for messages; minimize metadata where possible.  
3. **Offline capable** — Stations install and run from local cache; Server enhances sync but isn’t mandatory for Builder.  
4. **Federation over centralization** — Friend’s server is queried for *their* public graph, not one global DB.  
5. **Invert incentives** — Marketplace and social should reward **direct exchange** between people, not engagement farming.

## Relationship to Sandbox Music

The music console (`sovereign-music-console`) is **Station: Music** plus the first production **Sandbox Server** implementation. OS notes live in this repo; code for Music stays there until stations are extracted into a shared SDK.

See [MUSIC-CONSOLE-LINK.md](./MUSIC-CONSOLE-LINK.md).
