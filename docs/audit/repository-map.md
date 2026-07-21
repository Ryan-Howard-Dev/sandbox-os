# Repository Map — Pass 1 Inventory

**Repository:** `sandbox-os`  
**Pass:** 1 (Inventory)  
**Inventory date:** 2026-07-20  
**Constraint:** Classify top-level entries only. No subsystem analysis.

---

## Classification legend

| Class | Meaning (Pass 1) |
|-------|------------------|
| **Stable** | Relatively settled role; expected to remain; low churn expected for structure |
| **Evolving** | Active / primary working surface; content or role still changing |
| **Experimental** | Exploratory helpers; may be replaced or moved |
| **Deprecated** | Explicitly superseded; kept for history |
| **Dead** | Present but unused / empty / no clear owner |

---

## Top-level map (`sandbox-os`)

| Path | Class | Notes |
|------|-------|-------|
| `docs/` | **Evolving** | Primary product of this repo — vision, ADRs, station specs, adoption. High document count; content still advancing (many files touched 2026-07-20). |
| `docs/audit/` | **Evolving** | New this pass; discovery artifacts for multi-pass audit. Not final docs. |
| `scripts/` | **Experimental** | Thin WSL/Windows helpers for tier34 bench; path-hardcoded; not a packaged toolchain. |
| `scripts/wsl/` | **Experimental** | Only subdirectory under `scripts/`; five operator entrypoints. |
| `README.md` | **Stable** | Canonical entry and sibling-repo table; role unlikely to change. |
| `.gitignore` | **Stable** | Minimal ignore rules (`node_modules`, logs, env). |
| `.git/` | **Stable** | Git metadata (excluded from content search). |
| `.vscode/` | **Dead** | Directory present; no inventoried settings/extensions JSON in Pass 1. |

### Absent top-level (notable for a “vision” repo)

| Typical name | Present? | Note |
|--------------|----------|------|
| `src/`, `app/`, `lib/` | No | No application source |
| `package.json` | No | No Node package |
| `image/`, `shell/` | No | Live in sibling `sandbox-os-core` |
| `tests/` | No | — |

---

## Ecosystem context (outside this Git root — not classified as in-repo dirs)

Pass 1 recorded sibling checkouts for dependency awareness only:

| Path | Observed top-level (sample) | Role relative to this repo |
|------|-----------------------------|----------------------------|
| `../sandbox-os-core` | `docs`, `image`, `scripts`, `server`, `shell`, `spread`, `stations` | Bootable shell / ISO / Spread — **implementation chassis** |
| `../sovereign-music-console` | `src`, `tier34-server`, `src-tauri`, `android`, `docs`, … | Music station + household server |
| `../sandbox-conduit (1)` | `apps`, `src`, `src-tauri-browser`, `server`, … | Builder + Tide browser |

These are **separate repositories**. Their internal directories are **not** classified in this map. Recommend dedicated Pass 1 maps per sibling if the audit expands.

---

## Structural summary

```text
sandbox-os/                    [vision + ops helpers]
├── README.md                  Stable
├── .gitignore                 Stable
├── .git/                      Stable (VCS)
├── .vscode/                   Dead (empty of config)
├── docs/                      Evolving (primary)
│   └── audit/                 Evolving (Pass 1 artifacts)
└── scripts/                   Experimental
    └── wsl/                   Experimental
```

**Repo role (inventory statement):** Documentation-and-dev-bench repository for Sandbox OS. Not a bootable OS tree.

## Halt

Pass 1 repository map complete. Execution stops here per Pass 1 constraints.
