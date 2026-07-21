# Search Scope — Pass 1 Inventory

**Repository root:** `C:\Users\RH\Downloads\sandbox-os`  
**Pass:** 1 (Inventory)  
**Inventory date:** 2026-07-20  
**Constraint:** Discovery artifact defining what Pass 1 searched and what it excluded.

---

## Directories / files searched

### Included (full inventory)

| Path | How searched | Result |
|------|--------------|--------|
| `README.md` | Read + listed | Present |
| `docs/` (all `*.md` at top of docs) | Glob + header skim + cross-link grep | 23 markdown files (pre-audit) |
| `docs/audit/` | Created this pass | 4 discovery artifacts |
| `scripts/` | Recursive list + content skim | `scripts/wsl/` — 5 scripts |
| `.gitignore` | Read | Present |
| Top-level directory listing | `Get-ChildItem -Force` | `.git`, `.vscode`, `docs`, `scripts`, `.gitignore`, `README.md` |
| Sibling existence check (paths only) | `Test-Path` under `Downloads\` | Confirmed checkouts exist for core / music / conduit |

### Explicit file list searched under `docs/` (pre-audit)

- `BUILT-IN-MAIL.md`
- `BUILT-IN-PLATFORM.md`
- `BUILT-IN-VPN.md`
- `CHRONICLE.md`
- `CONDUIT-LINK.md`
- `DECISIONS.md`
- `ETHICS-AND-ECONOMICS.md`
- `FIRE-TABLET.md`
- `FUNDING.md`
- `GETTING-STARTED.md`
- `GLOSSARY.md`
- `INSTALL-AND-ADOPTION.md`
- `MARKETPLACE.md`
- `MUSIC-CONSOLE-LINK.md`
- `NETWORK-OVERLAY-GHOST.md`
- `ONBOARDING-BUILDING-BLOCKS.md`
- `PHASES.md`
- `PLATFORM-AND-KERNEL.md`
- `SPREAD-PHONE-TO-PHONE.md`
- `THREAT-MODEL-TARGETED.md`
- `VAULT-PASSWORDS.md`
- `VISION.md`
- `WSL-DEV-SETUP.md`

### Explicit file list searched under `scripts/`

- `scripts/wsl/install-debian-wsl.ps1`
- `scripts/wsl/open-tier34-in-cursor.ps1`
- `scripts/wsl/setup-dev-bench.sh`
- `scripts/wsl/start-tier34-and-wait.ps1`
- `scripts/wsl/tier34-status.ps1`

---

## Files / directories excluded

| Path | Reason for exclusion |
|------|----------------------|
| `.git/` | Version control metadata; not product documentation or source surface for architecture inventory |
| `.git/hooks/*.sample` | Default Git sample hooks; not project-authored |
| `.vscode/` | Present as empty/local IDE folder; no project settings files found to inventory |
| `node_modules/` | Named in `.gitignore`; not present / not applicable (no package.json) |
| `*.log`, `.env`, `.env.*` | Ignored by `.gitignore`; secrets/noise — not searched |
| `C:\Users\RH\Downloads\sandbox-os-core\**` | **Out of repository root.** Sibling OS implementation repo. Pass 1 for *this* repo does not inventory its tree (existence + top-level names only for dependency map). |
| `C:\Users\RH\Downloads\sovereign-music-console\**` | **Out of repository root.** Music + tier34 implementation. Existence + top-level names only. |
| `C:\Users\RH\Downloads\sandbox-conduit (1)\**` | **Out of repository root.** Builder / Tide. Existence + top-level names only. |
| Agent transcripts / Cursor cache / plugin paths | Outside repo; not part of product tree |
| Binary / media assets | None present in this repo |

---

## Search methods used

| Method | Purpose |
|--------|---------|
| Recursive glob / directory listing | Enumerate all tracked-ish files under root |
| Header / first-section skim of each `docs/*.md` | Purpose column for documentation manifest |
| Grep of docs for cross-links (`sandbox-os-core`, `tier34`, `conduit`, etc.) | Depends On / external references |
| Script content skim | External tool and path dependencies |
| Sibling `Test-Path` + top-level name list | Dependency and repository-map context only |

---

## Scope statement for later passes

- **Pass 1 (this file):** Inventory of `sandbox-os` only.
- **Recommended later:** Separate Pass 1 inventories (or a multi-root Pass) for `sandbox-os-core`, `sovereign-music-console`, and `sandbox-conduit (1)` if the audit target is the full Sandbox OS *ecosystem*.
- Relative doc links such as `../sandbox-os-core/docs/...` imply a **documentation dependency** on files outside this Git root; those files were **not** opened for content audit in Pass 1.

## Halt

Pass 1 search-scope definition complete. No subsystem analysis performed.
