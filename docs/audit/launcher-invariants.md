# Launcher Invariants — Pass 2

**Subsystem:** Node.js Station Launcher & Daemon  
**Code root:** `sandbox-os-core/shell/` (+ `server/health-check.mjs`)  
**Pass:** 2 (Subsystem Audit)  
**Audit date:** 2026-07-21  
**Rule:** Evidence-backed from executable code only.

| Invariant | Why it matters | Evidence | Violation risk |
|-----------|----------------|----------|----------------|
| Launcher HTTP daemon binds only to `127.0.0.1` | Limits remote abuse of static serve + station spawn API | `launcher-server.mjs` `server.listen(PORT, '127.0.0.1', …)` | **Medium** — if bind host is later changed without auth, LAN can spawn processes |
| Default listen port is `3002` unless `SANDBOX_LAUNCHER_PORT` set | Predictable Home URL for session autostart | `PORT = Number(process.env.SANDBOX_LAUNCHER_PORT) \|\| 3002` | **Low** — conflict if another service uses 3002 (catalog music `devUrl` also uses 3002) |
| Static files are served only from `shell/launcher/` or `shell/design/` with path prefix check | Prevents arbitrary filesystem read via HTTP | `file.startsWith(root)` before `readFileSync` | **Medium** — classic prefix checks can fail on some path normalizations; no `path.resolve` canonicalize |
| HTML responses inject `window.SANDBOX_TIER34_URL` from server env | Client and daemon share same tier34 base URL | replace `</head>` with script assigning `SANDBOX_TIER34_URL` | **Low** |
| Station spawn via HTTP only accepts POST `/stations/launch` with JSON `{ id }` | Narrow control plane for process launch | `url === '/stations/launch' && req.method === 'POST'` | **High** — no auth/token; any local process can POST |
| Spawn child always runs `launch.mjs` with station id argv | Single spawn entrypoint | `spawn(process.execPath, [LAUNCH_SCRIPT, id], …)` | **Low** |
| `launch.mjs` refuses non-`spawn` kinds | Panels/settings must not be launched as binaries | `if (station.kind !== 'spawn') process.exit(1)` | **Low** if UI wrongly POSTs panel ids (HTTP returns `ok: false`) |
| Unknown station id → exit 1 | Fail closed on bad ids | `findStation` miss → `process.exit(1)` | **Low** |
| Detached binary spawn uses `stdio: 'ignore'` and `unref()` | Station process outlives launcher child | `spawnBinary` | **Low** |
| Dev-URL fallback uses OS opener (`xdg-open` / `open` / `cmd start`) | Allows station open without installed binary | `openUrl` | **Medium** — opens arbitrary catalog/env URL in default browser |
| UI identity for platform writes is hardcoded `sandbox-dev-key-001` | Demo authorship until keys exist | `LOCAL_KEY` in `app.js` | **High** — spoofable / non-sovereign identity |
| Panel payloads send plaintext `payload.text` (and listing fields) to tier34 | No client-side E2E in launcher | `loadSocial` / `loadMessages` POST bodies | **High** vs product claims of E2E |
| User-supplied text rendered via `escapeHtml` | XSS mitigation for outbox HTML | `escapeHtml` used in list templates | **Medium** — only applied where used; meta fields also escaped for titles/descriptions |
| Catalog is loaded from `/stations/catalog.json` at init | Labels/icons/hints can come from catalog | `loadCatalog` + `applyCatalogHints` | **Medium** — grid buttons are hardcoded in HTML; catalog cannot add/remove tiles alone |
| Stations without a loader or special-case handler show “coming soon” alert | Incomplete stations fail soft | click handler final `alert(… coming soon)` | **Low** |
| Session start may probe tier34 then start compositor | Health failure does not block desktop (`\|\| true`) | `sandbox-session.sh` `health-check.mjs \|\| true` | **Low** — intentional soft fail |
| Autostart starts launcher daemon then opens third-party browser to `:3002` | Home UI is browser-hosted, not a native window | `config/sway/autostart`, `config/labwc/autostart` | **High** vs “Tide is product browser” — Firefox/Chromium wedge in code |

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/launcher-server.mjs
    - ../sandbox-os-core/shell/stations/launch.mjs
    - ../sandbox-os-core/shell/stations/catalog.json
    - ../sandbox-os-core/shell/launcher/app.js
    - ../sandbox-os-core/shell/launcher/index.html
    - ../sandbox-os-core/shell/sandbox-session.sh
    - ../sandbox-os-core/shell/config/sway/autostart
    - ../sandbox-os-core/shell/config/labwc/autostart
  symbols:
    - createServer
    - launchStation
    - resolveBinary
    - spawnBinary
    - openUrl
    - LOCAL_KEY
    - escapeHtml
    - loaders
  confidence: High
  evidence_type:
    - implementation
    - configuration
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/design/tokens.css
    - ../sandbox-os-core/shell/launcher/styles.css
    - ../sandbox-os-core/server/health-check.mjs
```

## Halt

Pass 2 invariants for Node.js Station Launcher & Daemon complete.
