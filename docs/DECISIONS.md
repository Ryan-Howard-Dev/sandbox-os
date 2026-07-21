# Architecture decisions (immutable)

**Last updated:** 2026-07-07

Recorded choices that should **not be re-litigated** every session unless there is strong new evidence. To change a decision: add a new dated entry at the bottom with **supersedes** and **reason**.

---

## D-001 — Linux base, not scratch kernel

**Decision:** Sandbox OS starts on **Linux** (drivers, power, LTS). Custom kernel only if Linux fails a hard security requirement later.

**Reason:** Phones and desktops need drivers now; kernel team is a decade-scale distraction.

**Supersedes:** Building an OS from bare metal for v1.

---

## D-002 — Three-repo split (Music / Conduit / OS notes)

**Decision:**

| Repo | Path | Role |
|------|------|------|
| **Music** | `sovereign-music-console` | Station: Media + **tier34-server** (port 3001) |
| **Conduit** | `sandbox-conduit (1)` (`sandbox-builder` in package.json) | Station: Builder + creative stations (port 5174) |
| **OS** | `sandbox-os` | Vision, chronicle, decisions, phases — **no app code** until `os-core` extract |

**Reason:** Music and Conduit are both large (~120k+ LOC each); merging creates unmaintainable shell. OS docs stay separate from shipping apps.

**Supersedes:** Putting OS manifesto only inside music repo.

---

## D-003 — tier34 is the single home-server hub

**Decision:** One **Sandbox Server (tier34)** per household runs from **Music repo** (`tier34-server/`). Conduit and Music UIs are **clients** that share `sandbox_tier34_backend_url`.

**Reason:** Locker blobs, Feed, acquire, Connect already live in tier34. Conduit docs confirm it does not bundle tier34.

**Not yet:** Conduit Feed/locker sync UI fully wired — health probe only today.

**See:** `sandbox-conduit (1)/docs/tier34-connection.md`

---

## D-004 — Lane A wedge (sovereign locker player)

**Decision:** Ship **“I own my music”** before **“replace iOS.”** Priority: locker sync Phase 3, stable playback on real phone, signed Android/F-Droid, spine tests.

**Reason:** Defensible niche; no other app combines locker + yt-dlp + vinyl + tier34 + OpenSubsonic this way.

**Supersedes:** Competing with Spotify catalog scale as primary goal.

---

## D-005 — Followed-artist release polling: 12 hours

**Decision:** Background check for new releases from followed artists runs on a **12-hour** interval (not 60s / 5min).

**Reason:** User rejected aggressive polling — battery and trust cost.

**Supersedes:** 60s foreground / 5min background polling proposal.

---

## D-006 — Fan counts are not global by default

**Decision:** Locker/catalog artist pages show **local library stats** (albums · tracks). No fake “324K fans” without federation or labeled external API.

**Reason:** Sovereign model — no central spy database of who follows whom.

**Future:** Optional federation or TheAudioDB-style external stat, clearly labeled.

---

## D-007 — Follows are device-local until server sync ships

**Decision:** `followedArtists` lives in device prefs until `/api/social/*` on tier34 is implemented.

**Reason:** Incremental path — household sync before friend federation.

---

## D-008 — Stream-first on cellular

**Decision:** Prefer **stream URL → play immediately**; full yt-dlp download in background or as fallback. Do not force double full download before first sound on mobile.

**Reason:** 15–30s silence on cellular was unacceptable; verified on device testing.

**Key fix theme:** Gate `androidPreferWatchForFullTrack` when stream URL exists.

---

## D-009 — Don’t boil the ocean (release scope)

**Decision:** Each phase ships **one provable loop** before banking, national voting, or mass OS replacement marketing.

**Reason:** Scope kills solo builders; 20-year vision stays, 6-month proof matters.

**See:** [GLOSSARY.md](./GLOSSARY.md)

---

## D-010 — Identity: keys first; hosted auth optional

**Decision:** Core OS identity is **cryptographic keys** (Ed25519 fingerprints, taste signing). **Clerk** in Conduit is an **optional hosted** layer for Builder tenants — not the sovereign default for OS 0.1.

**Reason:** Freedom narrative requires offline/local identity; SaaS auth is a product mode, not the root trust model.

---

## D-011 — Federation over central social graph

**Decision:** Cross-user follows/likes flow via **self-hosted server outbox** and optional server-to-server pull — not a single Sandbox Inc. database.

**Reason:** Aligns with sovereignty; matches deferred ActivityPub direction in `federated-taste.md`.

**Not built:** ActivityPub inbox/outbox.

---

## D-012 — Marketplace on locker, not central DB

**Decision:** Future marketplace listings are **locker objects** on seller’s node; discovery is federated/trusted-circle, not one eBay-shaped warehouse.

**Reason:** “Infrastructure already on planet” — invert priority to peer freedom.

**See:** [MARKETPLACE.md](./MARKETPLACE.md)

---

## D-013 — Conduit = Builder station pack

**Decision:** **sandbox-conduit** remains the **Builder / creative station** implementation (Sand, Sandstone, Reef, Ocean, Shore, Tide, Horizon). Extract shared shell to `os-core` later; do not merge into Music repo.

**Reason:** ~608 TS/TSX files, own Express tenant server (5174), compile pipeline, Stripe/Clerk — distinct product surface.

**See:** [CONDUIT-LINK.md](./CONDUIT-LINK.md)

---

## D-014 — Phone E2E before trusting playback fixes

**Decision:** Playback and vinyl fixes must be validated on **physical device** with **uncached** tracks — not only emulator or cached Father/Bully paths.

**Reason:** Repeated user feedback: agent tests did not match real cellular lag.

**Script:** `sovereign-music-console/scripts/phone-playback-vinyl-e2e.ps1` (device `46349770` reference).

---

## D-015 — Chronicle discipline

**Decision:** After each design session, append to `CHRONICLE.md` in the relevant repo(s). Immutable choices go here in `DECISIONS.md`.

**Reason:** Chat history is not due diligence or memory for future you.

---

## Change log

| Date | ID | Change |
|------|-----|--------|
| 2026-07-07 | D-001–D-015 | Initial decisions record from Music + OS design sessions; Conduit audit added (D-002, D-013) |
