# Deployment Analysis — Pass 2

**Subsystem:** Deployment Automation (`spread-host.mjs` + USB writer)  
**Code root:** `sandbox-os-core/spread/`  
**Pass:** 2 (Subsystem Audit)  
**Audit date:** 2026-07-21  
**Constraint:** Claims grounded in code. Confidence: High / Medium / Low / Unknown.

---

## Interfaces

Extracted from executable code and the catalog it reads.

### CLI — `spread/host/spread-host.mjs`

| Aspect | Interface |
|--------|-----------|
| **Inputs** | `argv`: `list` \| `check` \| `prepare-usb <block-device>` \| `--help`/`-h`; optional `--dry-run`; filesystem `spread/catalog/devices.json`; ISO path from catalog `image.path` joined to core root |
| **Outputs** | stdout catalog/status text; stderr errors; process exit `0`/`1`; on `prepare-usb`, inherits child bash exit status |
| **State changes** | None in Node itself; `prepare-usb` triggers destructive USB write via shell |
| **External dependencies** | Node `fs`, `path`, `child_process.spawnSync`; `bash` + `write-usb.sh` for prepare; on Windows `where` for tool probe; on Unix `command -v` |
| **Called by** | Human / scripts invoking `node spread/host/spread-host.mjs …` (no in-repo callers found outside Spread docs/README) |
| **Calls into** | `bash write-usb.sh <device> <iso> [--dry-run]` |
| **Persistence** | None (reads catalog/ISO; does not write state files) |
| **Threading/async** | Synchronous CLI (`spawnSync`); no event loop server |

### Writer — `spread/host/write-usb.sh`

| Aspect | Interface |
|--------|-----------|
| **Inputs** | CLI: `<block-device> [iso-path] [--dry-run]`; must run as root; default ISO `image/out/sandbox-os-0.1-amd64.iso` under core root |
| **Outputs** | Console progress; `dd` to block device; exit `0`/`1` |
| **State changes** | Overwrites target block device contents |
| **External dependencies** | `lsblk`, `blockdev`, `dd`, `findmnt`, `stat`, `sync`, `grep`, bash |
| **Called by** | Direct `sudo bash write-usb.sh …` or via `spread-host.mjs prepare-usb` |
| **Calls into** | Linux block layer via `dd`/`blockdev` |
| **Persistence** | USB contents only |
| **Threading/async** | Single-threaded shell; `dd` blocks until complete |

### Catalog — `spread/catalog/devices.json` (+ unused `schema.json`)

| Aspect | Interface |
|--------|-----------|
| **Inputs** | Static JSON consumed by Host CLI |
| **Outputs** | Device metadata for list/check/prepare |
| **Persistence** | File on disk; not modified by Host |

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/host/spread-host.mjs
    - ../sandbox-os-core/spread/host/write-usb.sh
    - ../sandbox-os-core/spread/catalog/devices.json
  symbols:
    - main
    - cmdList
    - cmdCheck
    - cmdPrepareUsb
    - loadCatalog
    - resolveImagePath
  confidence: High
  evidence_type:
    - implementation
    - configuration
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/README.md
    - ../sandbox-os-core/spread/receiver/README.md
```

---

## Verified Facts

Only statements directly supported by code / runtime config.

### 1. `spread-host.mjs` is a Node CLI with three operational commands

`list`, `check`, `prepare-usb`; unknown command prints usage and exits 1.

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/host/spread-host.mjs
  symbols:
    - main
    - printUsage
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/host/write-usb.sh
```

### 2. Core root is resolved as two levels above `spread/host/`

`CORE_ROOT = resolve(__dirname, '../..')`; catalog at `spread/catalog/devices.json`.

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/host/spread-host.mjs
  symbols:
    - CORE_ROOT
    - CATALOG_PATH
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/catalog/devices.json
```

### 3. Only one catalog device exists and it is `pc-amd64-live-usb` with `status: "available"`

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/catalog/devices.json
  symbols: []
  confidence: High
  evidence_type:
    - configuration
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/catalog/schema.json
```

### 4. Image path in catalog is relative: `image/out/sandbox-os-0.1-amd64.iso`

Resolved via `join(CORE_ROOT, rel)`.

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/catalog/devices.json
    - ../sandbox-os-core/spread/host/spread-host.mjs
  symbols:
    - resolveImagePath
  confidence: High
  evidence_type:
    - configuration
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/host/write-usb.sh
```

### 5. `list` prints each device’s metadata and whether the ISO file exists

Does not exit non-zero solely for missing ISO.

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/host/spread-host.mjs
  symbols:
    - cmdList
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/host/write-usb.sh
```

### 6. `check` only evaluates devices with `status === 'available'`

Skips non-available entries (none present today besides available).

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/host/spread-host.mjs
  symbols:
    - cmdCheck
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/catalog/devices.json
```

### 7. `check` fails closed on missing ISO; missing tools are warnings

Tool probe uses `where` (Windows) or `command -v` (else).

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/host/spread-host.mjs
  symbols:
    - cmdCheck
    - commandExists
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/host/write-usb.sh
```

### 8. `prepare-usb` exits 1 on Windows without invoking the writer

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/host/spread-host.mjs
  symbols:
    - cmdPrepareUsb
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/host/write-usb.sh
```

### 9. `prepare-usb` hardcodes lookup of `pc-amd64-live-usb`

Does not take a catalog device id argument.

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/host/spread-host.mjs
  symbols:
    - cmdPrepareUsb
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/catalog/devices.json
```

### 10. `prepare-usb` invokes `bash` with `write-usb.sh`, USB device, ISO path, optional `--dry-run`

Uses `spawnSync` with `stdio: 'inherit'`.

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/host/spread-host.mjs
  symbols:
    - cmdPrepareUsb
    - WRITE_USB
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/catalog/schema.json
```

### 11. `write-usb.sh` requires root and a block device

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/host/write-usb.sh
  symbols: []
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/host/spread-host.mjs
```

### 12. Writer safety gates: partition-name heuristic, system-disk refuse, mounted-partition refuse, size check, typed confirmation

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/host/write-usb.sh
  symbols: []
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/host/spread-host.mjs
```

### 13. Dry-run path never calls `dd`

Prints intended command and exits 0.

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/host/write-usb.sh
  symbols: []
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/host/spread-host.mjs
```

### 14. Destructive path runs `dd … bs=4M status=progress conv=fsync`, then `sync` and optional `blockdev --flushbufs`

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/host/write-usb.sh
  symbols: []
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/catalog/devices.json
```

### 15. Default ISO path inside writer matches catalog filename under `image/out/`

`DEFAULT_ISO="$CORE_ROOT/image/out/sandbox-os-0.1-amd64.iso"`.

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/host/write-usb.sh
    - ../sandbox-os-core/spread/catalog/devices.json
  symbols: []
  confidence: High
  evidence_type:
    - implementation
    - configuration
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/catalog/schema.json
```

### 16. Host CLI never reads `schema.json`

No `schema` path/import in `spread-host.mjs`.

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/host/spread-host.mjs
    - ../sandbox-os-core/spread/catalog/schema.json
  symbols:
    - loadCatalog
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/catalog/devices.json
```

### 17. Catalog `minBytes` and `usbMinGiB` are not referenced by Host CLI or writer

Size enforcement uses `stat`/`blockdev` on actual ISO and device.

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/catalog/devices.json
    - ../sandbox-os-core/spread/host/spread-host.mjs
    - ../sandbox-os-core/spread/host/write-usb.sh
  symbols:
    - cmdCheck
    - cmdPrepareUsb
  confidence: High
  evidence_type:
    - configuration
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/catalog/schema.json
```

### 18. No Spread Receiver executable exists under `spread/receiver/`

Only `README.md` stating stub / not implemented.

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/receiver/README.md
  symbols: []
  confidence: High
  evidence_type:
    - configuration
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/host/spread-host.mjs
    - ../sandbox-os-core/spread/host/write-usb.sh
```

### 19. `prepare-usb` does not invoke `sudo` itself

Root check is inside `write-usb.sh`; Node merely runs `bash`.

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/host/spread-host.mjs
    - ../sandbox-os-core/spread/host/write-usb.sh
  symbols:
    - cmdPrepareUsb
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/catalog/devices.json
```

### 20. No automated tests for Spread Host/writer found under `spread/`

Only host scripts, catalog, README, receiver stub.

```yaml
evidence:
  files: []
  symbols: []
  confidence: Medium
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/host/spread-host.mjs
    - ../sandbox-os-core/spread/host/write-usb.sh
    - ../sandbox-os-core/spread/README.md
    - ../sandbox-os-core/spread/receiver/README.md
```

### 21. Confidence Unknown: whether `image/out/sandbox-os-0.1-amd64.iso` exists on a given machine at audit time

This pass did not treat ISO presence as a permanent code fact (artifact is environmental).

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/catalog/devices.json
  symbols:
    - resolveImagePath
  confidence: Unknown
  evidence_type:
    - configuration
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/host/spread-host.mjs
```

### 22. Post-write message claims guided install on first boot; no installer implementation is part of this subsystem’s code

Message is a string in `write-usb.sh` only.

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/host/write-usb.sh
  symbols: []
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/host/spread-host.mjs
    - ../sandbox-os-core/spread/receiver/README.md
```

---

## Architectural Interpretation

### A. Deployment automation v0 is “catalog + readiness + raw USB image write”

Not a general installer framework, OTA, signing pipeline, or multi-device flasher. The Node CLI is a thin orchestrator around one bash writer.

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/host/spread-host.mjs
    - ../sandbox-os-core/spread/host/write-usb.sh
    - ../sandbox-os-core/spread/catalog/devices.json
  symbols:
    - cmdPrepareUsb
  confidence: High
  evidence_type:
    - implementation
    - configuration
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/receiver/README.md
```

### B. Catalog is aspirationally multi-device; prepare path is single-device hardcoded

Schema enums include phone/tablet and wifi-direct/nfc; executable prepare ignores that breadth.

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/catalog/schema.json
    - ../sandbox-os-core/spread/host/spread-host.mjs
    - ../sandbox-os-core/spread/catalog/devices.json
  symbols:
    - cmdPrepareUsb
  confidence: High
  evidence_type:
    - configuration
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/host/write-usb.sh
```

### C. Windows is a check/list host; Linux/WSL is the write host

Platform branch in `prepare-usb` plus WARN text in `check` encode that split.

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/host/spread-host.mjs
  symbols:
    - cmdPrepareUsb
    - cmdCheck
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/host/write-usb.sh
```

### D. Safety model is heuristic + human confirmation, not cryptographic attestation

No image signature verify, no catalog signature, no measured boot checks before `dd`.

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/host/write-usb.sh
    - ../sandbox-os-core/spread/host/spread-host.mjs
  symbols:
    - cmdPrepareUsb
  confidence: High
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/catalog/schema.json
    - ../sandbox-os-core/spread/receiver/README.md
```

### E. Schema file documents a single device object; `devices.json` is a wrapper catalog document

`$schema` points at `./schema.json`, but schema `required`/`properties` describe one device, not `{version, updated, devices[]}`. Runtime never validates either shape.

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/catalog/schema.json
    - ../sandbox-os-core/spread/catalog/devices.json
    - ../sandbox-os-core/spread/host/spread-host.mjs
  symbols:
    - loadCatalog
  confidence: Medium
  evidence_type:
    - configuration
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/host/write-usb.sh
```

### F. Partition-digit heuristic is incomplete for modern disk names

`nvme0n1` ends with a digit and would be rejected as a “partition” even when it is a whole disk; conversely some partition naming schemes might slip through. Confidence **Medium** (logic is clear; real-world naming edge cases not tested in-repo).

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/host/write-usb.sh
  symbols: []
  confidence: Medium
  evidence_type:
    - implementation
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/host/spread-host.mjs
```

---

## Engineering Assessment

### Strengths

1. **Clear v0 scope** — list/check/prepare-usb for one PC live ISO is understandable and auditable. Confidence: **High**.  
2. **Meaningful USB safety gates** — root required, block device check, root-disk refuse, mount check, size check, typed confirm, dry-run. Confidence: **High**.  
3. **Fail closed on missing ISO for check/prepare**. Confidence: **High**.  
4. **Separation of concerns** — Node orchestration vs shell destructive I/O. Confidence: **High**.

### Weaknesses / risks

1. **Still catastrophic if the wrong disk is confirmed** — `dd` to whole disk; confirmation is the last line of defense. Confidence: **High**.  
2. **No image/catalog signing or integrity verify** before write. Confidence: **High**.  
3. **Catalog breadth vs code** — multi-device schema vs hardcoded `pc-amd64-live-usb`. Confidence: **High**.  
4. **`check` can pass without USB tools** (WARN only) — easy to misread as fully ready. Confidence: **High**.  
5. **No sudo elevation in Node** — UX footgun (`node prepare-usb` then bash dies needing root). Confidence: **High**.  
6. **Unused catalog constraints** (`minBytes`, `usbMinGiB`) and **unused schema validation**. Confidence: **High**.  
7. **Receiver / phone Spread not in executable path** — docs/stubs only. Confidence: **High**.  
8. **Post-write “guided install” is aspirational copy**, not enforced by this subsystem. Confidence: **High**.  
9. **No tests**. Confidence: **Medium**.

### Assessment summary

Deployment Automation today is a **competent v0 USB imaging toolkit** for the single `pc-amd64-live-usb` path, with above-average shell safety for a `dd` wrapper, fronted by a small Node catalog CLI. It is **not** yet a multi-device Spread platform, signed deployment pipeline, or installer automation system.

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/host/spread-host.mjs
    - ../sandbox-os-core/spread/host/write-usb.sh
    - ../sandbox-os-core/spread/catalog/devices.json
    - ../sandbox-os-core/spread/catalog/schema.json
    - ../sandbox-os-core/spread/receiver/README.md
  symbols:
    - cmdCheck
    - cmdPrepareUsb
    - loadCatalog
  confidence: High
  evidence_type:
    - implementation
    - configuration
counter_evidence:
  files_inspected:
    - ../sandbox-os-core/spread/README.md
    - ../sandbox-os-core/shell/launcher-server.mjs
```

## Halt

Pass 2 module audit for Deployment Automation (`spread-host.mjs`) complete.
