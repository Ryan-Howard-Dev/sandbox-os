# Documentation Manifest — Pass 1 Inventory

**Repository:** `sandbox-os`  
**Pass:** 1 (Inventory)  
**Inventory date:** 2026-07-20  
**Scope:** Files present under this repository only. Sibling repos referenced as dependency targets, not inventoried here.  
**Constraint:** Discovery artifact — not a subsystem analysis.

| Document | Purpose | Generated From | Last Audited | Confidence | Depends On |
|----------|---------|----------------|--------------|------------|------------|
| `README.md` | Repo entry: north star, sibling project table, start-here index, principles, ideation status | Human author / design conversations | 2026-07-20 | High | `docs/VISION.md`, `docs/CHRONICLE.md`, `docs/PHASES.md`, sibling paths `sovereign-music-console`, `sandbox-conduit (1)` |
| `docs/VISION.md` | What Sandbox OS is and why (sovereign stations, keys, local-first) | Design conversations | 2026-07-20 | High | — |
| `docs/CHRONICLE.md` | Dated design notes with sources | Design conversations | 2026-07-20 | Medium | `docs/VISION.md`, conversation history |
| `docs/PHASES.md` | Phased roadmap (velocity-recalibrated) | Design conversations + velocity notes | 2026-07-20 | Medium | `docs/VISION.md`, `docs/DECISIONS.md` |
| `docs/DECISIONS.md` | Immutable architecture choices (ADRs) | Architecture decisions | 2026-07-20 | High | `docs/VISION.md` |
| `docs/GLOSSARY.md` | Shared terms (e.g. “don’t boil the ocean”) | Design conversations | 2026-07-20 | High | — |
| `docs/GETTING-STARTED.md` | On-ramp for contributors / builders | Human author | 2026-07-20 | Medium | `docs/VISION.md`, `docs/WSL-DEV-SETUP.md`, sibling repos |
| `docs/WSL-DEV-SETUP.md` | Windows + WSL2 workbench; tier34 on `:3001` | Dev bench practice | 2026-07-20 | High | `scripts/wsl/*`, `sovereign-music-console` (tier34) |
| `docs/MUSIC-CONSOLE-LINK.md` | Maps Sandbox Music / tier34 to OS stations | Cross-repo audit notes | 2026-07-20 | Medium | `../sovereign-music-console`, `docs/DECISIONS.md` |
| `docs/CONDUIT-LINK.md` | Maps Sandbox Conduit (Builder / Tide) to OS | Cross-repo audit notes | 2026-07-20 | Medium | `../sandbox-conduit (1)`, `docs/DECISIONS.md` |
| `docs/BUILT-IN-PLATFORM.md` | Stations-not-store platform stance; station inventory | Architecture / product | 2026-07-20 | High | `docs/VISION.md`, `../sandbox-os-core/docs/STATIONS-ARCHITECTURE.md` (external) |
| `docs/BUILT-IN-VPN.md` | Native WireGuard / Ghost Network station spec (not Proton wrapper) | Architecture | 2026-07-20 | Medium | `docs/NETWORK-OVERLAY-GHOST.md`, `docs/BUILT-IN-PLATFORM.md`, `sandbox-os-core` stations docs (external) |
| `docs/BUILT-IN-MAIL.md` | Native Mail station + optional tier34 mail module | Architecture | 2026-07-20 | Medium | `docs/BUILT-IN-PLATFORM.md`, `docs/VAULT-PASSWORDS.md`, `sandbox-os-core` (external) |
| `docs/VAULT-PASSWORDS.md` | Password / passkey Vault station spec | Architecture | 2026-07-20 | Medium | `docs/BUILT-IN-PLATFORM.md`, `sandbox-os-core` Vault/TIER34 docs (external) |
| `docs/NETWORK-OVERLAY-GHOST.md` | Ghost overlay / mesh privacy network concept | Architecture / threat thinking | 2026-07-20 | Medium | `docs/BUILT-IN-VPN.md`, `docs/THREAT-MODEL-TARGETED.md` |
| `docs/THREAT-MODEL-TARGETED.md` | Targeted-adversary threat model | Security architecture | 2026-07-20 | Medium | `docs/VISION.md`, `docs/NETWORK-OVERLAY-GHOST.md` |
| `docs/PLATFORM-AND-KERNEL.md` | Platform vs kernel / OS base strategy | Architecture | 2026-07-20 | Medium | `docs/VISION.md`, `docs/DECISIONS.md` |
| `docs/INSTALL-AND-ADOPTION.md` | Spread / Hydra mass-adoption install story | Product / go-to-market | 2026-07-20 | Medium | `docs/SPREAD-PHONE-TO-PHONE.md`, `docs/FIRE-TABLET.md`, `docs/ONBOARDING-BUILDING-BLOCKS.md` |
| `docs/ONBOARDING-BUILDING-BLOCKS.md` | Existing building blocks for Spread onboarding | Research / inventory notes | 2026-07-20 | Medium | `docs/INSTALL-AND-ADOPTION.md`, Conduit mDNS (external) |
| `docs/SPREAD-PHONE-TO-PHONE.md` | Phone→phone Spread protocol / UX v1 | Spec | 2026-07-20 | Medium | `docs/INSTALL-AND-ADOPTION.md`, `sandbox-os-core/spread` (external) |
| `docs/FIRE-TABLET.md` | Amazon Fire sideload / client wedge (not full OS replace) | Hardware adoption research | 2026-07-20 | Medium | `docs/INSTALL-AND-ADOPTION.md`, `docs/SPREAD-PHONE-TO-PHONE.md` |
| `docs/MARKETPLACE.md` | Locker-native marketplace concept | Product | 2026-07-20 | Medium | `docs/VISION.md`, `docs/DECISIONS.md`, tier34 platform (external) |
| `docs/ETHICS-AND-ECONOMICS.md` | Hosted membership ethics; self-host free | Policy / economics | 2026-07-20 | High | `docs/FUNDING.md`, `docs/VISION.md` |
| `docs/FUNDING.md` | Backers, grants, job vs full-time build | Funding notes | 2026-07-20 | High | `docs/ETHICS-AND-ECONOMICS.md` |
| `docs/audit/documentation-manifest.md` | Pass 1 master TOC of documentation | Pass 1 inventory | 2026-07-20 | High | Entire `docs/` + `README.md` |
| `docs/audit/dependencies.md` | Pass 1 internal/external dependency inventory | Pass 1 inventory | 2026-07-20 | High | `scripts/`, docs cross-links, sibling repos |
| `docs/audit/search-scope.md` | Pass 1 search inclusion/exclusion bounds | Pass 1 inventory | 2026-07-20 | High | Repository layout |
| `docs/audit/repository-map.md` | Pass 1 top-level directory classification | Pass 1 inventory | 2026-07-20 | High | Top-level tree |
| `docs/audit/launcher-invariants.md` | Pass 2 invariants — Station Launcher & Daemon | Pass 2 code audit | 2026-07-21 | High | `sandbox-os-core/shell/` |
| `docs/audit/launcher-analysis.md` | Pass 2 analysis — Station Launcher & Daemon | Pass 2 code audit | 2026-07-21 | High | launcher invariants |
| `docs/audit/deployment-invariants.md` | Pass 2 invariants — Spread Host | Pass 2 code audit | 2026-07-21 | High | `sandbox-os-core/spread/` |
| `docs/audit/deployment-analysis.md` | Pass 2 analysis — Spread Host | Pass 2 code audit | 2026-07-21 | High | deployment invariants |
| `docs/audit/provider-invariants.md` | Pass 2 invariants — Provider / model routing | Pass 2 code audit | 2026-07-21 | High | `sandbox-conduit (1)/` |
| `docs/audit/provider-analysis.md` | Pass 2 analysis — Provider / model routing | Pass 2 code audit | 2026-07-21 | High | provider invariants |
| `docs/BUILT-IN-DOCS.md` | Docs/Sheets station spec — conflict copies, Vault secrets, formats | Product architecture | 2026-07-23 | High | `BUILT-IN-PLATFORM.md`, `VAULT-PASSWORDS.md`, D-016 |
| `docs/diataxis.md` | Diátaxis quadrant map of this docs suite | Portfolio prep | 2026-07-22 | High | All `docs/*.md` |
| `docs/portfolio/github-profile-README.md` | Copy for `Ryan-Howard-Dev/Ryan-Howard-Dev` profile repo | Portfolio prep | 2026-07-22 | High | Public GitHub URLs |
| `docs/portfolio/PUBLISH.md` | Steps to publish / pin / open issues | Portfolio prep | 2026-07-22 | High | — |

## Inventory notes (Pass 1 only)

- This repository contains **no application runtime** beyond helper scripts under `scripts/wsl/`.
- Several docs **depend on paths outside this repo** (`sandbox-os-core`, `sovereign-music-console`, `sandbox-conduit (1)`). Those targets are listed in Depends On but were **not** audited as documents in this pass.
- `docs/MUSIC-CONSOLE-LINK.md` and related link docs may lag sibling implementation status; Confidence Medium until Pass 2+ cross-checks.
- No prior `docs/audit/` artifacts existed before this pass.

## Halt

Pass 1 documentation inventory complete. Do not treat this file as final platform documentation.
