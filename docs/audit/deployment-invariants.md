# Deployment Invariants — Pass 2

**Subsystem:** Deployment Automation (`spread-host.mjs` + USB write path)  
**Code root:** `sandbox-os-core/spread/`  
**Pass:** 2 (Subsystem Audit)  
**Audit date:** 2026-07-21  
**Rule:** Evidence-backed from executable code / config consumed by that code.

| Invariant | Why it matters | Evidence | Violation risk |
|-----------|----------------|----------|----------------|
| Host CLI commands are only `list`, `check`, `prepare-usb` (plus help) | Narrow deployment control plane | `main()` switch on `positional[0]` | **Low** |
| Catalog is loaded from `spread/catalog/devices.json` relative to core root | Single source of device/image metadata for CLI | `CATALOG_PATH`, `loadCatalog()` | **Medium** — no runtime schema validation; malformed JSON crashes |
| `check` fails (exit 1) if any `status === 'available'` device lacks a present ISO file | Prevents claiming readiness without image | `cmdCheck` sets `ok = false` → `process.exit(1)` | **Low** |
| Missing host tools on `check` are **WARN**, not FAIL | Windows hosts can check ISO without Linux `dd` | `tools: WARN missing…`; exit still 0 if ISO OK | **Medium** — “Check passed” can hide inability to write USB on that host |
| `prepare-usb` refuses `win32` and directs to WSL/Linux | Avoids native Windows block-device write path | `process.platform === 'win32'` → exit 1 | **Low** |
| `prepare-usb` only uses catalog entry `id === 'pc-amd64-live-usb'` with `status === 'available'` | Hard-wires v0 PC USB path | `catalog.devices.find((d) => d.id === 'pc-amd64-live-usb' && …)` | **High** — adding catalog devices does not extend prepare without code change |
| `prepare-usb` requires ISO file to exist before invoking writer | Fail closed on missing image | `existsSync(isoPath)` else exit 1 | **Low** |
| USB write is delegated to `write-usb.sh` via `bash` + `spawnSync` | Destructive I/O isolated in shell script | `spawnSync('bash', [WRITE_USB, usbDevice, isoPath, …])` | **Medium** — depends on `bash` in PATH; inherits stdio |
| `write-usb.sh` requires root (`id -u` == 0) | Block device write needs privilege | `die "root required"` | **Low** if caller forgets sudo (`prepare-usb` does not auto-escalate) |
| Writer target must be a block device (`-b`) | Rejects regular files as `of=` | `[[ -b "$DEVICE" ]]` | **Low** |
| Writer rejects devices whose name ends in a digit (partition heuristic) | Prefer whole-disk targets | regex `[0-9]$` | **Medium** — false positives/negatives on naming schemes (e.g. `nvme0n1`) |
| Writer refuses the disk backing `/` | Avoid wiping running system root | `findmnt` + `lsblk PKNAME` vs `DEVICE_BASE` | **Medium** — incomplete for multi-disk / bind-mount / WSL edge cases |
| Writer refuses device with mounted partitions | Avoid writing mounted USB | `lsblk MOUNTPOINT` grep `/` | **Medium** |
| Writer refuses USB smaller than ISO byte size | Prevent truncated writes | `DEV_BYTES < ISO_BYTES` → die | **Low** |
| Non–dry-run write requires typed confirmation equal to `basename(DEVICE)` | Human gate before `dd` | `read -r -p` / `CONFIRM == DEVICE_BASE` | **High** if confirmation bypassed or scripted without review |
| `--dry-run` prints intended `dd` and exits 0 without writing | Safe rehearsal | `DRY_RUN=1` branch before confirm/`dd` | **Low** |
| Actual write uses `dd if=ISO of=DEVICE bs=4M status=progress conv=fsync` then `sync` | Bootable raw image copy | end of `write-usb.sh` | **High** — wrong device still catastrophic despite guards |
| Catalog fields `image.minBytes` and `requirements.usbMinGiB` are not enforced by Host CLI/writer | Documented requirements may not match runtime checks | Present in `devices.json`; unused in `.mjs`/`.sh` | **Medium** — size check uses live ISO/device bytes instead |
| `schema.json` is not loaded or validated by `spread-host.mjs` | Schema is documentation-only at runtime | No imports/reads of `schema.json` in host code | **Medium** — invalid catalog shapes only fail at parse/use time |
| Spread Receiver is not implemented in this subsystem’s executable path | Phone/network install out of scope for v0 host | `receiver/README.md` stub; no receiver `.mjs`/`.sh` | **Low** for PC USB v0; **High** if product claims phone Spread works |

```yaml
evidence:
  files:
    - ../sandbox-os-core/spread/host/spread-host.mjs
    - ../sandbox-os-core/spread/host/write-usb.sh
    - ../sandbox-os-core/spread/catalog/devices.json
    - ../sandbox-os-core/spread/catalog/schema.json
    - ../sandbox-os-core/spread/receiver/README.md
  symbols:
    - loadCatalog
    - cmdList
    - cmdCheck
    - cmdPrepareUsb
    - commandExists
    - resolveImagePath
    - main
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

Pass 2 invariants for Deployment Automation complete.
