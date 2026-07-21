# Launcher Analysis — Pass 2

**Subsystem:** Node.js Station Launcher & Daemon  
**Code root:** `sandbox-os-core/shell/` (+ `server/health-check.mjs`)  
**Pass:** 2 (Subsystem Audit)  
**Audit date:** 2026-07-21  
**Constraint:** Claims grounded in code. Confidence: High / Medium / Low / Unknown.

---

## Interfaces

Extracted from executable / configuration code (not docs).

### Daemon (`launcher-server.mjs`)

| Aspect | Interface |
|--------|-----------|
| **Inputs** | HTTP on `127.0.0.1:(SANDBOX_LAUNCHER_PORT\|\|3002)`; env `SANDBOX_LAUNCHER_PORT`, `SANDBOX_TIER34_URL`; filesystem under `shell/launcher`, `shell/design`, `shell/stations` |
| **Outputs** | Static assets; GET `/stations/catalog.json`; POST `/stations/launch` → JSON `{ ok, id, code, log }`; console log of listen URL |
| **State changes** | No durable daemon state; spawns short-lived Node child per launch; injects tier34 URL into HTML |
| **External dependencies** | Node `http`, `fs`, `path`, `url`, `child_process`; optional tier34 URL for HTML inject only |
| **Called by** | Manual `node shell/launcher-server.mjs`; sway/labwc `autostart`; `sandbox-session.sh` (indirect via compositor autostart) |
| **Calls into** | `shell/stations/launch.mjs` via `spawn(process.execPath, [LAUNCH_SCRIPT, id])` |
| **Persistence** | None |
| **Threading/async** | Single-threaded Node event loop; `async` request handler; `launchStation` Promise waits on child `close`; `readBody` Promise on stream |

### Station spawn helper (`stations/launch.mjs`)

| Aspect | Interface |
|--------|-----------|
| **Inputs** | CLI argv station id; `catalog.json`; env `SANDBOX_TIER34_URL`, `SANDBOX_<ID>_BIN`, `SANDBOX_<ID>_DEV_URL`, `SANDBOX_CONDUIT_ROOT` (browser) |
| **Outputs** | stdout/stderr logs; exit 0 on success, 1 on failure; may spawn detached binary or OS URL opener |
| **State changes** | Starts external OS processes (station binary or browser) |
| **External dependencies** | Catalog; optional binaries; `xdg-open`/`open`/`cmd` |
| **Called by** | `launcher-server.mjs` `launchStation` |
| **Calls into** | OS process table / default browser |
| **Persistence** | None |
| **Threading/async** | `async launchStation`; `spawnBinary` Promise on `spawn`/`error` |

### Browser UI (`launcher/app.js` + `index.html`)

| Aspect | Interface |
|--------|-----------|
| **Inputs** | User clicks on hardcoded `[data-station]` buttons; `window.SANDBOX_TIER34_URL`; catalog JSON |
| **Outputs** | DOM panels; `fetch` to tier34 platform APIs; `fetch` POST `/stations/launch`; `window.open` / `alert` |
| **State changes** | In-memory `activeStation`, `catalog`; DOM panel visibility; **no** localStorage |
| **External dependencies** | Launcher daemon (same origin); tier34 HTTP API |
| **Called by** | Browser loading Home page |
| **Calls into** | tier34 `/health`, `/api/social/*`, `/api/marketplace/listings`, `/api/share`; launcher `/stations/*` |
| **Persistence** | None in launcher UI (platform persistence is tier34, outside this subsystem) |
| **Threading/async** | Browser event loop; `async` loaders; `AbortSignal.timeout` on several fetches |

### Session glue

| Aspect | Interface |
|--------|-----------|
| **Inputs** | Env `SANDBOX_OS_CORE`, `SANDBOX_TIER34_URL`; presence of `labwc`/`sway`/`node` |
| **Outputs** | Copies compositor configs; may run health probe; `exec` compositor |
| **Calls into** | `server/health-check.mjs` (soft); compositor + autostart scripts that start launcher daemon |

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/launcher-server.mjs
    - ../sandbox-os-core/shell/stations/launch.mjs
    - ../sandbox-os-core/shell/launcher/app.js
    - ../sandbox-os-core/shell/sandbox-session.sh
    - ../sandbox-os-core/shell/config/sway/autostart
  symbols:
    - createServer
    - launchStation
    - readBody
    - resolveBinary
    - api
    - loaders
  confidence: High
  evidence_type:
    - implementation
    - configuration
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/docs/STATIONS-ARCHITECTURE.md
    - ../sandbox-os-core/docs/PLATFORM-API.md
```

---

## Verified Facts

Only statements directly supported by code.

### 1. The daemon is a Node HTTP static server plus two station control routes

`launcher-server.mjs` creates `node:http` `createServer`, serves files from `LAUNCHER_DIR` / `DESIGN_DIR`, and special-cases GET catalog + POST launch.

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/launcher-server.mjs
  symbols:
    - createServer
    - MIME
    - LAUNCHER_DIR
    - DESIGN_DIR
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/launcher/app.js
```

### 2. Listen address is loopback-only; default port 3002

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/launcher-server.mjs
  symbols:
    - PORT
    - server.listen
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/stations/catalog.json
```

### 3. POST `/stations/launch` has no authentication

Any client that can reach `127.0.0.1:3002` may POST `{ "id": "…" }` and trigger `launch.mjs`.

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/launcher-server.mjs
  symbols:
    - launchStation
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/launcher/app.js
    - ../sandbox-os-core/server/health-check.mjs
```

### 4. Catalog defines station kinds: `launcher`, `spawn`, `panel`, `external`

Present ids include `home`, `browser`, `social`, `messages`, `marketplace`, `music`, `mail`, `vpn`, `share`, `builder`, `settings`.

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/stations/catalog.json
  symbols: []
  confidence: High
  evidence_type:
    - configuration
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/launcher/index.html
```

### 5. HTML grid hardcodes eight stations; catalog also lists `mail` and `vpn` (and `home`) with no matching buttons

`index.html` buttons: browser, social, messages, marketplace, music, share, builder, settings. No `mail` / `vpn` / `home` tiles.

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/launcher/index.html
    - ../sandbox-os-core/shell/stations/catalog.json
  symbols: []
  confidence: High
  evidence_type:
    - implementation
    - configuration
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/launcher/app.js
```

### 6. `launch.mjs` only launches `kind === "spawn"` stations

Non-spawn ids exit with error.

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/stations/launch.mjs
  symbols:
    - launchStation
    - findStation
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/launcher/app.js
```

### 7. Binary resolution order: env bin → (browser) conduit Tauri paths → absolute `binaryPaths` → relative name / `binary` → `devUrl` / env override

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/stations/launch.mjs
  symbols:
    - resolveBinary
    - openUrl
    - spawnBinary
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/stations/catalog.json
```

### 8. UI panel stations call tier34 with hardcoded `LOCAL_KEY = 'sandbox-dev-key-001'`

Used for social posts, messages, marketplace listings, share.

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/launcher/app.js
  symbols:
    - LOCAL_KEY
    - loadSocial
    - loadMessages
    - loadMarketplace
    - loadShare
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/stations/launch.mjs
```

### 9. Message / post bodies are plaintext JSON fields; no encryption APIs in launcher UI

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/launcher/app.js
  symbols:
    - api
    - loadMessages
    - loadSocial
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/launcher-server.mjs
```

### 10. `escapeHtml` is defined and used for displayed outbox text/titles in list renderers

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/launcher/app.js
  symbols:
    - escapeHtml
    - renderList
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/launcher/index.html
```

### 11. Spawn UX prefers reachable `devUrl` via `window.open` before POST `/stations/launch`

`openBrowser`, `openMusic`, `openBuilder` call `devUrlReachable` then optionally `spawnStation`.

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/launcher/app.js
  symbols:
    - openBrowser
    - openMusic
    - openBuilder
    - devUrlReachable
    - spawnStation
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/stations/launch.mjs
```

### 12. Catalog sets music `devUrl` to `http://localhost:3002` — same default as the launcher daemon

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/stations/catalog.json
    - ../sandbox-os-core/shell/launcher-server.mjs
  symbols:
    - PORT
  confidence: High
  evidence_type:
    - configuration
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/launcher/app.js
```

### 13. `devUrlReachable` uses `fetch(..., { mode: 'no-cors' })` and treats non-throw as reachable

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/launcher/app.js
  symbols:
    - devUrlReachable
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/stations/launch.mjs
```

### 14. Autostart starts `launcher-server.mjs` then opens Firefox ESR / Chromium to Home URL

Comment in sway autostart explicitly marks Firefox as TEMP / TODO replace with sandbox-browser.

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/config/sway/autostart
    - ../sandbox-os-core/shell/config/labwc/autostart
  symbols: []
  confidence: High
  evidence_type:
    - configuration
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/stations/launch.mjs
```

### 15. `sandbox-session.sh` prefers `labwc` over `sway` if both exist; soft-fails tier34 health

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/sandbox-session.sh
    - ../sandbox-os-core/server/health-check.mjs
  symbols:
    - main
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/launcher/app.js
```

### 16. Launcher UI has no `localStorage` / `sessionStorage` usage

Grep of `app.js` shows no persistence APIs.

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/launcher/app.js
  symbols:
    - activeStation
    - catalog
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/launcher/index.html
```

### 17. VPN panel has no loader; click would hit “coming soon” if a button existed

`loaders` only maps social, messages, marketplace, share. Catalog `vpn` is `kind: panel` but absent from HTML and loaders.

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/launcher/app.js
    - ../sandbox-os-core/shell/stations/catalog.json
    - ../sandbox-os-core/shell/launcher/index.html
  symbols:
    - loaders
  confidence: High
  evidence_type:
    - implementation
    - configuration
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/stations/launch.mjs
```

### 18. Browser catalog `devUrl` is `:5175/tide?mode=os`; `openBrowser` fallback string uses `:5174/tide?mode=os` if catalog missing

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/stations/catalog.json
    - ../sandbox-os-core/shell/launcher/app.js
  symbols:
    - openBrowser
  confidence: High
  evidence_type:
    - configuration
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/stations/launch.mjs
```

### 19. Daemon does not implement process supervision, restart, or PID tracking of launched stations

`launchStation` in server only waits for `launch.mjs` exit code/logs; `launch.mjs` unrefs detached children.

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/launcher-server.mjs
    - ../sandbox-os-core/shell/stations/launch.mjs
  symbols:
    - launchStation
    - spawnBinary
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/sandbox-session.sh
```

### 20. No unit/integration tests for launcher daemon or UI found under `sandbox-os-core/shell/`

```yaml
evidence:
  files: []
  symbols: []
  confidence: Medium
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/launcher-server.mjs
    - ../sandbox-os-core/shell/stations/launch.mjs
    - ../sandbox-os-core/shell/launcher/app.js
    - ../sandbox-os-core/shell/install-labwc.sh
```

---

## Architectural Interpretation

Inferences from repository structure and how the pieces compose. Not stronger than evidence allows.

### A. “Daemon” is a local Home server, not a long-lived station supervisor

The Node process is an HTTP front door for Home UI and a thin spawn proxy. It does not manage station lifecycle after `launch.mjs` returns.

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/launcher-server.mjs
    - ../sandbox-os-core/shell/stations/launch.mjs
  symbols:
    - createServer
    - spawnBinary
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/config/sway/autostart
```

### B. Dual station model: in-shell panels vs out-of-process spawns

Panels (`social`, `messages`, `marketplace`, `share`) are SPA views over tier34. Spawns (`browser`, `music`, `builder`, catalog `mail`) are external apps/URLs. `settings` opens tier34 health in a new tab.

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/stations/catalog.json
    - ../sandbox-os-core/shell/launcher/app.js
  symbols:
    - loaders
    - openBrowser
    - openMusic
    - openBuilder
  confidence: High
  evidence_type:
    - implementation
    - configuration
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/docs/STATIONS-ARCHITECTURE.md
```

### C. Catalog is advisory for UI labels; grid membership is HTML-authored

`applyCatalogHints` mutates existing buttons; it cannot create tiles for `mail`/`vpn`.

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/launcher/app.js
    - ../sandbox-os-core/shell/launcher/index.html
  symbols:
    - applyCatalogHints
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/stations/catalog.json
```

### D. Music `devUrl` colliding with launcher port likely causes false-positive “music is up”

If Home is serving on 3002, `devUrlReachable('http://localhost:3002')` with `no-cors` will typically not throw, so `openMusic` may `window.open` the launcher again instead of spawning Music.

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/launcher/app.js
    - ../sandbox-os-core/shell/stations/catalog.json
    - ../sandbox-os-core/shell/launcher-server.mjs
  symbols:
    - openMusic
    - devUrlReachable
  confidence: Medium
  evidence_type:
    - implementation
    - configuration
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/stations/launch.mjs
```

### E. Product browser wedge: session opens Firefox/Chromium, while Browser station aims at Tide binary/dev URL

Architecture intent is visible in TODO comments + catalog `sandbox-browser` paths, but boot path still launches firefox-esr first.

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/config/sway/autostart
    - ../sandbox-os-core/shell/stations/catalog.json
    - ../sandbox-os-core/shell/stations/launch.mjs
  symbols:
    - resolveBinary
  confidence: High
  evidence_type:
    - configuration
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/launcher/app.js
```

### F. Identity and cryptography are outside this subsystem’s implementation

Launcher treats `authorKeyId` as a string constant. No signing, keygen, or vault bridge in these files.

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/launcher/app.js
  symbols:
    - LOCAL_KEY
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/launcher-server.mjs
    - ../sandbox-os-core/shell/stations/launch.mjs
```

### G. Confidence Unknown: whether ISO image currently ships identical launcher sources

Live-build worktree copies exist under `image/live-build-work/...`; this pass did not diff them to source of truth beyond noting copies exist.

```yaml
evidence:
  files:
    - ../sandbox-os-core/image/live-build-work/config/includes.chroot/opt/sandbox-os-core/shell/launcher-server.mjs
  symbols: []
  confidence: Unknown
  evidence_type:
    - configuration
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/shell/launcher-server.mjs
```

---

## Engineering Assessment

Quality judgments grounded in the verified facts above.

### Strengths

1. **Small, readable control plane** — one server file + one spawn script + one UI script is easy to audit.  
   Confidence: **High** (structure of files listed above).

2. **Loopback bind** reduces remote attack surface relative to `0.0.0.0`.  
   Confidence: **High**.

3. **XSS hygiene** on rendered outbox fields via `escapeHtml`.  
   Confidence: **High** for those call sites.

4. **Kind gate** in `launch.mjs` prevents treating panels as binaries.  
   Confidence: **High**.

### Weaknesses / risks

1. **Unauthenticated local spawn API** — any local malware/user script can POST station launches. Acceptable for early demo; insufficient for a “daemon” security story. Confidence: **High**.

2. **Hardcoded demo key + plaintext platform posts** — contradicts sovereign/E2E narrative if this UI is presented as product Social/Messages. Confidence: **High**.

3. **Catalog vs HTML drift** (`mail`, `vpn` unused; music port collision; browser port 5174 vs 5175 fallback). Confidence: **High** for drift facts; **Medium** for user-visible music mis-open hypothesis.

4. **`no-cors` reachability probe is unreliable** — opaque success does not prove the intended station service. Confidence: **High**.

5. **Not a supervisor** — no restart, health of child stations, or single-instance locks. Naming it a “daemon” overstates operational maturity. Confidence: **High**.

6. **Firefox/Chromium boot wedge** remains in configuration despite Tide station paths. Confidence: **High**.

7. **No tests** under shell for launch semantics. Confidence: **Medium**.

### Assessment summary

The Node.js Station Launcher & Daemon is a **credible Phase-1 Home shell**: local static UI, tier34 panel demos, and best-effort spawn/open of external stations. It is **not** yet a hardened OS service (auth, identity, supervision, catalog-driven UI, first-party browser-at-boot).

```yaml
evidence:
  files:
    - ../sandbox-os-core/shell/launcher-server.mjs
    - ../sandbox-os-core/shell/stations/launch.mjs
    - ../sandbox-os-core/shell/launcher/app.js
    - ../sandbox-os-core/shell/stations/catalog.json
    - ../sandbox-os-core/shell/config/sway/autostart
  symbols:
    - LOCAL_KEY
    - devUrlReachable
    - launchStation
  confidence: High
  evidence_type:
    - implementation
    - configuration
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/docs/STATIONS-ARCHITECTURE.md
    - ../sandbox-os-core/shell/DESIGN.md
```

## Halt

Pass 2 module audit for Node.js Station Launcher & Daemon complete. No Pass 3 executed.
