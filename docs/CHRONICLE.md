# Chronicle — design conversations (dated)

Working log of ideas discussed while shaping Sandbox OS. Not a commit history — a **memory for future you**.

**Music app sessions (playback, locker, vinyl, CI):** `../sovereign-music-console/docs/CHRONICLE.md`  
**Funding / backers:** [FUNDING.md](./FUNDING.md)

**Workflow:** After each design session, append a dated section here before context lives only in chat.

---

## 2026-05 (~) — Sandbox Music begins

- **~6 weeks** (founder estimate) to reach current **Sovereign Music Console** scope.  
- Multi-target: Web/PWA, Android (Capacitor), Tauri desktop, **tier34 Sandbox Server**.  
- Scale (2026-07 audit): ~567 TS/Rust files, ~120k LOC in music repo.  
- Music path: `C:\Users\RH\Downloads\sovereign-music-console`

---

## 2026-06 — Music as Station #1 (summary)

Major work happened in music repo before OS was named separately. See music `CHRONICLE.md` for detail. Themes that **carry into OS**:

- Locker as universal blob store (music today → marketplace photos tomorrow).  
- tier34 as per-household anchor node.  
- Identity signing (taste manifests, Ed25519).  
- Federation sketch (`federated-taste.md`).  
- Infrastructure scaffold in Tauri (`identity_authority`, event bus).

---

## 2026-07-07 — Locker artist / Tidal parity (music station)

- Artist-first locker UX; Tidal-style profile requested.  
- Shipped in music repo: `LockerArtistHub`, Radio/Follow/Share, Top Tracks, carousels, Credits.  
- Fan counts deferred — need federation or external API, not device-local follows alone.

---

## 2026-07-07 — Social graph on Sandbox Server

**Questions:**

1. Can Server link accounts so people see follows/likes?  
2. Can each user’s Server **ping** other Servers worldwide for that data?

**Answers captured:**

| Layer | Status |
|-------|--------|
| Follows on device | Shipped (`followedArtists.ts`) |
| Sync follows to **your** tier34 | Not built — `/api/social/*` TBD |
| Server-to-server federation | Feasible; ActivityPub deferred |
| Global fan counts | Not sovereign-local; needs aggregator or external stat |

---

## 2026-07-07 — Full OS vision (founder)

**North star:** Own environment across devices — Music, Social, Builder, Marketplace, Vault, Vote — **freedom over priority**, not Windows/Android/iOS rent-seeking.

| Topic | Decision |
|-------|----------|
| Kernel | Start **Linux**, not scratch kernel |
| Builder | Offline signed station packages in minutes |
| Communication | E2E + self-hosted nodes; minimize corporate silos |
| Banking vault | P2P / community ledger long-term; law noted |
| Voting | Communities first; national = separate trust problem |
| “Don’t boil the ocean” | Ship one loop (identity + server + music) before bank/vote |

**Timeline debate:**

- Industry framing: 7+ years for mass OS replacement.  
- Founder velocity: music in ~6 weeks → software **demo** of OS 0.1 could be **months–18 months** if scoped.  
- **Adoption / law / hardware** clocks do not scale with typing speed.

See [PHASES.md](./PHASES.md), [GLOSSARY.md](./GLOSSARY.md).

---

## 2026-07-07 — Marketplace station (eBay / Vinted)

- Listings live in **locker**; discovery via federation, not one central DB.  
- “Infrastructure already on planet” — devices + storage; **invert incentive** to peer freedom.  
- Payments via Vault station later.  

See [MARKETPLACE.md](./MARKETPLACE.md).

---

## 2026-07-07 — Repository split

| Repo | Role |
|------|------|
| `sovereign-music-console` | Shippable Music + tier34 code |
| `sandbox-os` | Vision, chronicle, phases, funding notes |

Cross-link both READMEs and chronicles.

---

## 2026-07-07 — Chronicle discipline

- Music repo initially had **no** `CHRONICLE.md` — only OS repo did.  
- **Fixed:** both repos now maintain dated logs.  
- Rule: end of any session that changes direction → append section; link cross-repo when needed.

---

## 2026-07-07 — Funding & job vs build time

**Founder context:** Full-time job pulls away from build time.

**Captured in [FUNDING.md](./FUNDING.md):**

- Backers **not required** to ideate or ship Music updates.  
- **Likely helpful** for OS 0.1+ if calendar time is the bottleneck.  
- Backers exist in privacy/FOSS/grant/crowd niches — not typical mega-VC at “replace iOS” pitch.  
- Raise for **one milestone** (OS 0.1), not entire 20-year vision at once.  
- Music app is the **proof slide** for any conversation.

---

## 2026-07-07 — sandbox-conduit audit

**Path:** `C:\Users\RH\Downloads\sandbox-conduit (1)` (`sandbox-builder` in package.json).

**Finding:** Conduit is **mostly built** — ~608 frontend files, Express tenant server on **5174**, 7 creative stations (Horizon, Tide, Ocean, Sandstone, Sand, Reef, Shore), Sand compile pipeline, Sandstone templates, Tauri + local LLM + mDNS, Clerk/Stripe for hosted mode.

**OS reuse:**

| From Conduit | For OS |
|--------------|--------|
| Station shell + Horizon launcher | OS home registering all stations |
| Sand / Sandstone compile | **Builder station** (offline packages in minutes) |
| `identityBridge` + Tauri identity | Keys-first identity |
| `ecosystemConnection` / tier34 client | Shared hub URL with Music |
| mDNS peer discovery | LAN friend nodes (early federation) |

**Gaps:** tier34 Feed/locker **not wired** in Conduit UI (health probe only). tier34 server stays in **Music repo**.

**Decision recorded:** D-013 in [DECISIONS.md](./DECISIONS.md). Full audit: [CONDUIT-LINK.md](./CONDUIT-LINK.md).

---

## 2026-07-07 — DECISIONS.md created

Immutable choices documented: Linux base, three-repo split, tier34 hub, Lane A wedge, 12h polling, stream-first mobile, keys-not-accounts, federation, Conduit as Builder pack, phone E2E gate, chronicle discipline.

See [DECISIONS.md](./DECISIONS.md).

---

## 2026-07-12 — Stations architecture (lazy load, Tide browser, Music Tauri)

Explored **sandbox-conduit** (THE TIDE at `/tide`, `BrowserDashboard.tsx`) and **sovereign-music-console** (`sandboxLayer3.tsx`, Tauri desktop). Documented OS station model:

| Principle | Implementation |
|-----------|----------------|
| Boot = shell only | labwc/sway + `launcher-server.mjs`; no station binaries at login |
| Browser | Conduit Tide → future `sandbox-browser`; **not** Firefox/Chromium product browser |
| Music | sovereign-music-console Tauri; launcher must not open tier34 root URL |
| Catalog | `sandbox-os-core/shell/stations/catalog.json` + `launch.mjs` spawn stub |

ISO still ships `firefox-esr` as TEMP wedge until `sandbox-browser` is in the image. See `sandbox-os-core/docs/STATIONS-ARCHITECTURE.md`.

**Tide assessment follow-up:** No login vault today — recommend **OS-level Sandbox Vault** (E2E + tier34 sync, Tide autofill/passkey bridge, duress PIN) over Tide-embedded or Music locker; spec in [VAULT-PASSWORDS.md](./VAULT-PASSWORDS.md).

**Tide OS embed:** `?mode=os` hides Golden Path / Sandstone inject / agent deck; bookmarks + history stay (`tideBookmarks.ts` localStorage). tier34 library sync still open.

---

## 2026-07-12 — Built-in VPN, Mail, Media (spec + catalog)

Founder request: OS-level **VPN** (sovereign WireGuard, not Proton wrapper), **full email client** (IMAP/SMTP, not Gmail/Proton shell), and **Media** as first-class station (existing sovereign-music-console — packaging, not reimplementation).

| Station | Approach | Doc |
|---------|----------|-----|
| **Network / Ghost** | Native WireGuard + `sandbox-networkd`; Settings → Ghost Off/Home/Circle/Max | [BUILT-IN-VPN.md](./BUILT-IN-VPN.md) |
| **Mail** | `sandbox-mail` Tauri client; Vault creds; tier34 mail module optional v1+ | [BUILT-IN-MAIL.md](./BUILT-IN-MAIL.md) |
| **Media** | `sandbox-music` from sovereign-music-console; lazy spawn + tier34 systemd | [MUSIC-CONSOLE-LINK.md](./MUSIC-CONSOLE-LINK.md) |

**Honest scope:** VPN and mail are **large engineering** — this pass is architecture + `catalog.json` stubs (`vpn`, `mail`, `music`→Media label), not ISO binaries.

Updated: [BUILT-IN-PLATFORM.md](./BUILT-IN-PLATFORM.md), `sandbox-os-core/docs/STATIONS-ARCHITECTURE.md`, `shell/stations/catalog.json`.

---

## Open questions (carry forward)

1. Household sync vs friend federation — which first?  
2. Marketplace v0 — LAN/trusted friends only?  
3. Identity: Stronghold / Tauri path for all stations?  
4. Product name for public launch?  
5. When to extract `sandbox-sdk` from music repo?  
6. Grant applications (NLnet, STF, etc.) — worth applying?  
7. First git commit snapshot for `sandbox-os`?  
8. Add `docs/CHRONICLE.md` to Conduit repo?  
9. Extract `os-core` — from Conduit shell first?
