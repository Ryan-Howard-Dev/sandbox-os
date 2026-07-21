# Dependencies — Pass 1 Inventory

**Repository:** `sandbox-os`  
**Pass:** 1 (Inventory)  
**Inventory date:** 2026-07-20  
**Constraint:** Discovery artifact — tracks what exists and what is referenced. No subsystem deep-dive.

---

## Summary

| Class | Count (approx.) | Notes |
|-------|-----------------|-------|
| npm / package.json | **0** | No `package.json`, lockfile, or Node app in this repo |
| Internal modules (in-repo) | Scripts + docs only | No shared library modules |
| Sibling / ecosystem repos | **3** referenced | Not vendored; path-coupled on Windows Downloads |
| Host OS tools (scripts) | WSL, systemd, Node, QEMU, curl, apt | Required only for WSL bench scripts |

---

## Internal

Format: **Module | Used by | Imports | Purpose**

| Module | Used by | Imports | Purpose |
|--------|---------|---------|---------|
| `README.md` | Humans / Cursor | Links into `docs/*` | Entry and index |
| `docs/*.md` (vision set) | Humans / later audit passes | Cross-links among docs; some relative links to `../sandbox-os-core` | Architecture & product specs |
| `scripts/wsl/setup-dev-bench.sh` | Operator (WSL) | Host: `curl`, `apt`, `nodejs`/`npm`, `systemctl`, `loginctl`; path to `sovereign-music-console` | Install Node 22, QEMU, install/enable `tier34` systemd unit |
| `scripts/wsl/start-tier34-and-wait.ps1` | Operator (Windows) | Host: `wsl`, `Invoke-WebRequest` → `http://localhost:3001/health` | Restart WSL `tier34` and wait for health |
| `scripts/wsl/tier34-status.ps1` | Operator (Windows) | Host: `wsl`, `ss`, HTTP health | Quick tier34 / port 3001 status |
| `scripts/wsl/open-tier34-in-cursor.ps1` | Operator (Windows) | Host: HTTP health; may spawn `npm run start:tier34` in `sovereign-music-console` | Open `/health` in Cursor Simple Browser |
| `scripts/wsl/install-debian-wsl.ps1` | Operator (Windows) | Host: `wsl --install -d Debian` | Install Debian WSL distro |
| `.gitignore` | Git | — | Ignores `node_modules/`, logs, `.env*` |

### Internal dependency graph (simplified)

```text
README.md
  └─► docs/* (index)

docs/WSL-DEV-SETUP.md
  └─► scripts/wsl/*

scripts/wsl/*
  └─► [EXTERNAL] sovereign-music-console (tier34)
  └─► [HOST] WSL / Node / systemd / QEMU
```

No in-repo TypeScript/JavaScript modules import each other. Scripts do not import sibling scripts via modules; they are standalone entrypoints.

---

## External

### A. Sibling repositories (ecosystem, not packages)

| Package / Repo | Version | Required/Optional | Purpose |
|----------------|---------|-------------------|---------|
| `../sovereign-music-console` | Unpinned (local checkout) | **Required** for WSL/tier34 scripts and Music station narrative | Sandbox Music UI + `tier34-server` (`npm run start:tier34`, port 3001) |
| `../sandbox-os-core` | Unpinned (local checkout) | **Required** for bootable OS claims in docs; **not** imported by this repo’s code | Shell, ISO, Spread Host, launcher, stations catalog |
| `../sandbox-conduit (1)` | Unpinned (local checkout) | **Optional** for vision docs; **Required** for Browser/Builder station narrative | THE TIDE browser, Builder (`:5174`), Tauri browser tree |

**Path coupling risk:** Hardcoded Windows paths appear in scripts/docs (e.g. `C:\Users\RH\Downloads\sovereign-music-console`, `/mnt/c/Users/RH/Downloads/...`). Folder name `sandbox-conduit (1)` is fragile for automation.

### B. Host / runtime tools (consumed by scripts)

| Package | Version | Required/Optional | Purpose |
|---------|---------|-------------------|---------|
| WSL2 (`wsl`) | Host Windows feature | Required for `scripts/wsl/*.ps1` and bench | Linux side of workbench |
| Ubuntu WSL distro | Named `Ubuntu` in scripts | Required for status/start scripts as written | Runs systemd `tier34` unit |
| Debian WSL distro | Via `install-debian-wsl.ps1` | Optional | Alternate distro install helper |
| Node.js | **≥ 22** (script enforces major 22) | Required for tier34 on WSL | `node:sqlite` / `npm run start:tier34` |
| npm | Bundled with Node | Required for tier34 unit `ExecStart` | Starts music-console tier34 |
| systemd | Distro default | Required for `tier34` service | Auto-start Sandbox Server |
| QEMU (`qemu-system-x86`, `qemu-utils`, `ovmf`) | apt packages | Optional (ISO test) | Installed by `setup-dev-bench.sh` for ISO/QEMU testing |
| curl | Distro / NodeSource | Required for NodeSource setup in bench script | Bootstrap Node apt repo |
| NodeSource setup script | `setup_22.x` | Required if Node < 22 | External HTTPS install path |

### C. Package managers / lockfiles in this repo

| Item | Present? |
|------|----------|
| `package.json` | No |
| `package-lock.json` / `pnpm-lock.yaml` / `yarn.lock` | No |
| `Cargo.toml` | No |
| `requirements.txt` / `pyproject.toml` | No |
| Docker Compose | No |

### D. Documented external services (spec-level only — not dependencies of this repo’s code)

Listed because docs reference them as future/product dependencies; **not** installed or imported here:

| Package | Version | Required/Optional | Purpose |
|---------|---------|-------------------|---------|
| WireGuard | Unspecified | Future Network station | `BUILT-IN-VPN.md` |
| Stripe Connect (or similar) | Unspecified | Future marketplace fiat | Ethics/marketplace docs |
| IMAP/SMTP providers | Unspecified | Future Mail v0 | `BUILT-IN-MAIL.md` |

---

## Pass 1 findings (inventory only)

1. This repo’s executable surface is **script-only** and depends almost entirely on **sibling checkout paths + host WSL**.
2. There is **no declared dependency lockfile**; reproducibility of scripts relies on host state and sibling repos.
3. Cross-repo doc links treat `sandbox-os-core` as part of the documentation graph even though it is outside this Git root.

## Halt

Pass 1 dependency inventory complete.
