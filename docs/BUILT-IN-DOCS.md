# Built-in Docs — local-first documents & sheets

**Last updated:** 2026-07-23  
**Status:** Architecture / product spec only — **no implementation**  
**Prerequisite:** Do not start build until Music freeze/CI and OS chassis priorities allow; this is a **new product surface**, not a feature flag.  
**Stations doc:** [STATIONS-ARCHITECTURE.md](../sandbox-os-core/docs/STATIONS-ARCHITECTURE.md) (add Docs when implemented)

## Purpose

Sandbox OS ships a **first-party Docs station** — documents and spreadsheets that live in the **locker / household tier34**, under the **same keys** as Music, Mail, Vault, and Marketplace. Not Google Docs in a WebView. Not Microsoft 365. Not “Office Online” with a Sandbox skin.

**Stations, not apps** — Docs is a module of one OS, not a rented silo.

**Phased truth:** v0 is **open / edit / save local files** with honest sync semantics. Real-time multiplayer editing with strangers is **out of scope** (see [Won’t win soon](#wont-win-soon--honesty)). Household sync must **never silently eat work**.

---

## Better than Google *and* Microsoft — the wedge

You will not beat either at global real-time collab, template marketplaces, or enterprise compliance theater. You **can** beat both at **sovereign household documents**:

| Dimension | Google / Microsoft | Sandbox Docs |
|-----------|--------------------|--------------|
| Who owns the files | Their cloud / account graph | **Locker + optional tier34** — cloud is export, not home |
| Identity | Google / Microsoft account | **Same household keys** as every station |
| Surveillance | Ad / graph / telemetry businesses | **No docs telemetry**; no training on user content by default |
| Offline | Bolted on | **Default** |
| OS fit | Separate suite + Drive | **One station** — Browser downloads, Mail attach, Marketplace inventory, Builder export |
| Interchange | Proprietary lock-in | **Open interchange formats** (see below) — files still open if Sandbox dies |
| Household share | Corporate tenancy / “anyone with the link” | **Household sync** on *your* server; federation later |
| Secrets in sheets | Easy to paste tokens into synced cells | **Vault-linked secrets only** — structural, non-negotiable |
| AI | Forced cloud copilots | Local / BYOK / hosted — **user chooses** (Conduit pattern) |
| Pricing | “Free” = product | **$0 self-host** or clear hosted fee |

### Won’t win soon — honesty

Do **not** promise in marketing or v0 docs:

- Simultaneous editing with dozens of people as smooth as Google Docs / 365  
- Template / add-in ecosystems at Office scale  
- Enterprise retention, legal hold, DLP theater  
- “Everyone’s school/work already runs on Sandbox Docs”

---

## Forced design decision: household sync conflicts

**Problem:** Two people (or one person on phone + PC) edit the same document offline, then reconnect. “Household sync on your server” without a conflict policy is how sovereign tools **eat work**.

| Strategy | Pros | Cons | Verdict for Sandbox |
|----------|------|------|---------------------|
| **Last-write-wins (LWW)** | Simple | Silently discards one side | **Forbidden** for document / sheet **body** |
| **CRDT / OT real-time merge** | Seamless concurrent edit | Heavy; poor fit for binary ODF; Sheets hard | **Not v0**; optional later for Markdown-only collab |
| **Conflict copies** (Dropbox-style) | Never destroys either version; user decides | Manual resolve | **v0 required default** |
| **3-way merge** (text) | Clean when it works | Ambiguous for prose; wrong for binary | **Best-effort for Markdown/plain only**; fall back to conflict copy |

### Decision (v0 — binding for this spec)

1. **Document and sheet bodies never use silent LWW.**  
2. **Default conflict outcome = conflict copy:** keep the existing synced revision and write a sibling file, e.g.  
   `Budget.csv` + `Budget (conflict · Pixel-7 · 2026-07-23T14:02Z).csv`  
   (exact naming is UX polish; both files must remain openable interchange formats.)  
3. **Each revision carries:** content hash, `deviceId`, `updatedAt`, optional `parentHash` (causal hint — not a full CRDT).  
4. **Markdown / plain text:** attempt a **3-way merge** using `parentHash` when both sides share a common parent; on failure or ambiguity → **conflict copy**.  
5. **ODF / other binary office packages:** **conflict copy only** in v0–v1 — no auto-merge.  
6. **CSV / sheets:** **conflict copy only** in v0 — do not auto-merge rows.  
7. **Metadata only** (last opened path, window position): LWW allowed if documented as non-content.  
8. **UI must surface conflicts** — badge in Docs home + open both files; never hide a conflict copy in a trash the user never sees.

**v2+ (optional research):** CRDT (e.g. Automerge) for **Markdown collaborative notes** only, behind an explicit “live collab” mode — not the default household sync path, and never as an excuse to skip conflict copies for ODF/CSV.

**Open implementation questions (do not block the decision above):**

- Conflict copy naming / folder (`Conflicts/` vs sibling)  
- Whether tier34 stores both blobs under one logical `docId` or two locker entries  
- How Vault-encrypted docs conflict (two ciphertexts → two conflict copies; never merge ciphertext)

---

## Non-negotiable: vault-linked secrets

**Invariant:** Spreadsheets and documents **must not** become a plaintext sync channel for credentials, OAuth tokens, API keys, or refresh tokens.

This is the same failure class as secrets landing in logcat / investigation dumps on the Music side — a **Docs** sheet that syncs via tier34 is a worse blast radius if the boundary is soft.

| Rule | Requirement |
|------|-------------|
| Paste detection | Warn (v0) / block sync of cells matching high-entropy secret patterns (v1) when sync is enabled |
| Structural preference | “Insert from Vault” / reference by Vault item id — sheet stores **reference**, not secret material |
| Export | Exporting to CSV/ODF that would include resolved secrets requires an **explicit** “include secrets” confirm; default strips or re-vaults |
| Server | tier34 must not log document bodies; Vault ciphertext stays ciphertext |
| Tests | Spec requires automated tests before Docs sync ships: “token-like cell + sync enabled ⇒ blocked or vault-ref only” |

Soft warnings alone are **not** enough for v1 sync. v0 local-only may warn; **household sync of Docs does not ship** without the structural boundary.

---

## Formats (interchange vs implementation)

### User-visible interchange (must open if Sandbox dies)

| Format | Role |
|--------|------|
| **Markdown** (`.md`) | Default lightweight documents |
| **OpenDocument Text (`.odt`, `.ods`) | Office-compatible documents / sheets |
| **CSV** (`.csv`) | Sheet interchange |
| **Plain text** (`.txt`) | Notes, logs |

**Not** listed as interchange: proprietary-only `.docx`/`.xlsx` as *primary* — import/export may exist later; default save stays open.

### Implementation detail (not a “document format”)

| Mechanism | Role |
|-----------|------|
| **SQLite** (or similar) | Local **index, search, revision metadata, sync cursor** — an engine/cache, **not** the user’s document |
| Locker blob store | Bytes of the interchange file (+ optional ciphertext wrapper) |

A `.db` is not something a person opens in a text editor the way `.md` or `.odt` is. Product copy and README must not call SQLite an open document format.

---

## What we build

| Layer | Choice |
|-------|--------|
| **Station** | **Sandbox Docs** — `sandbox-docs` (Tauri or OS station binary); id `docs` in catalog |
| **Surfaces** | **Documents** + **Sheets** (Slides = later phase) |
| **Storage** | Interchange files in locker; optional E2E blob for sensitive docs |
| **Sync** | Household tier34 with **conflict copies** (above) |
| **Credentials / secrets** | **Sandbox Vault** only — never plaintext synced cells |
| **Network** | Optional Ghost Home/Circle for sync traffic |
| **Not shipping** | Google Docs / Office 365 WebView wrappers; Drive clone as v0 |

### Placement

| Place | Behavior |
|-------|----------|
| Launcher catalog | `id: docs`, kind `spawn` (or panel shell + editor), lazy-load — must not slow boot |
| Files / downloads | “Open in Docs” from Browser / Mail attachments |
| Builder | Export draft → Docs; Docs → static page compile (later) |
| Marketplace | Listing description / inventory sheet from Docs (later) |

---

## Architecture (target)

```text
┌─────────────────────────────────────────────────────────────┐
│  Sandbox Docs station                                        │
│  Home · Documents · Sheets · Conflicts inbox                 │
├─────────────────────────────────────────────────────────────┤
│  Editors (native Markdown + sheet grid; ODF via engine later)│
├─────────────────────────────────────────────────────────────┤
│  Revision + sync (hash, deviceId, parentHash, conflict copy) │
├─────────────────────────────────────────────────────────────┤
│  Sandbox Vault — secret refs; never plaintext sync           │
├─────────────────────────────────────────────────────────────┤
│  Locker / tier34 blobs — interchange file bytes              │
└─────────────────────────────────────────────────────────────┘
```

---

## Build path (honest tradeoffs)

| Path | Wins | Loses | Role in roadmap |
|------|------|-------|-----------------|
| **Lightweight native** (Markdown + simple grid) | Speed, privacy, OS fit, conflict story is clear | Heavy `.docx` fidelity | **v0–v1 default** |
| **OnlyOffice / Collabora self-hosted** | Office fidelity | Weight; feels like another server unless deeply embedded | Optional **import/compat** lane, not identity |
| **LibreOffice as wrapper station** | Compatibility | Risks “third-party wrapper” anti-pattern | **Avoid as product Docs** |

**Recommendation:** Native local-first Docs+Sheets that win on ownership and sync honesty; optional Office-format import via a contained engine later — **not** WebView Google Docs.

---

## Phased roadmap

| Phase | Scope | Sync | Secrets |
|-------|--------|------|---------|
| **v0** | Open/edit/save Markdown + CSV locally; Docs home; conflict UI stub | Off or LAN experimental with conflict copies | Warn on paste |
| **v1** | Household sync on tier34; ODF read or basic write; Conflicts inbox | **Conflict copies required** | Vault insert + block sync of raw secrets |
| **v1.5** | Mail attach / Browser open-with; Ghost for sync | Same | Same |
| **v2** | Optional Markdown live collab (CRDT) behind explicit mode; Sheets polish | CRDT never replaces conflict copies for ODF/CSV | Same |
| **Later** | Slides; Builder/Marketplace bridges | — | — |

**Planning only until:** Music freeze/CI green and OS owners schedule this surface. Spec ≠ license to start coding Docs.

---

## Station catalog sketch (when implementing)

```json
{
  "id": "docs",
  "label": "Docs",
  "kind": "spawn",
  "binary": "sandbox-docs",
  "tier34Required": false,
  "description": "Local-first documents and sheets — locker sync, conflict copies, Vault-linked secrets"
}
```

`tier34Required: false` for v0 offline; sync features degrade gracefully when server offline.

---

## Relation to other stations

| Station | Link |
|---------|------|
| **Vault** | Sole home for secrets referenced from sheets |
| **Mail** | Attach interchange files; never embed raw tokens |
| **Browser** | Downloads → Open in Docs |
| **Files** (if separate) | Docs can own editors; Files owns browse — or Docs Home *is* files for office types in v0 |
| **Builder** | Export/import later |
| **Marketplace** | Inventory sheets later |

---

## Open questions (non-conflict)

Conflict policy for v0 is **decided** above. Remaining:

1. Single “Files” station vs Docs-owned home for office types?  
2. ODF engine: embed vs external optional package?  
3. Mobile: full sheet grid vs documents-first on small screens?  
4. Hosted tier34: size quotas for doc blobs?

---

## See also

- [BUILT-IN-PLATFORM.md](./BUILT-IN-PLATFORM.md) — stations table  
- [VAULT-PASSWORDS.md](./VAULT-PASSWORDS.md) — credential vault  
- [MARKETPLACE.md](./MARKETPLACE.md) — future inventory bridge  
- [DECISIONS.md](./DECISIONS.md) — D-009 don’t boil the ocean; keys-first  
- [ETHICS-AND-ECONOMICS.md](./ETHICS-AND-ECONOMICS.md) — self-host vs hosted  

## Halt

This document is **spec only**. No Docs station code, catalog entry, or ISO packaging until an explicit build decision after Music freeze/CI and OS priority review.
