# WSL2 dev bench — Windows workbench

**Last updated:** 2026-07-07

Build Sandbox OS from Windows without dual-boot. WSL2 is the **factory**; Sandbox ISO is the **product**.

## What you have

| Piece | Role |
|-------|------|
| **WSL2 Ubuntu 24.04** | Build host (Debian optional — same script) |
| **tier34 systemd user service** | Sandbox Server on port **3001** |
| **QEMU** | Boot test ISOs when ready |

## One-time setup

**PowerShell:**

```powershell
wsl -d Ubuntu -- bash /mnt/c/Users/RH/Downloads/sandbox-os/scripts/wsl/setup-dev-bench.sh
```

**Optional Debian** (instead of or alongside Ubuntu):

```powershell
.\scripts\wsl\install-debian-wsl.ps1
wsl -d Debian -- bash /mnt/c/Users/RH/Downloads/sandbox-os/scripts/wsl/setup-dev-bench.sh
```

## Open tier34 **in Cursor** (not external browser)

```powershell
.\scripts\wsl\open-tier34-in-cursor.ps1
```

Or **Command Palette** → `Simple Browser: Show` → `http://localhost:3001/health`

**For IDE work:** run tier34 on **Windows** (stable for Cursor panel):

```powershell
cd C:\Users\RH\Downloads\sovereign-music-console
npm run start:tier34
```

Stop WSL tier34 first to avoid port fight: `wsl -d Ubuntu -- sudo systemctl stop tier34`

## Daily commands

| Task | Command |
|------|---------|
| tier34 status | `wsl -d Ubuntu -- sudo systemctl status tier34` |
| tier34 restart | `wsl -d Ubuntu -- sudo systemctl restart tier34` |
| tier34 logs | `wsl -d Ubuntu -- sudo journalctl -u tier34 -f` |
| Health (Windows browser) | http://localhost:3001 |
| QEMU version | `wsl -d Ubuntu -- qemu-system-x86_64 --version` |

## Test boot an ISO (when you have one)

```bash
qemu-system-x86_64 -m 4096 -smp 2 -enable-kvm \
  -cdrom /path/to/sandbox-os.iso
```

In WSL2, `-enable-kvm` may not work — drop it for software emulation (slower).

## Paths

| Windows | WSL |
|---------|-----|
| `C:\Users\RH\Downloads\sandbox-os` | `/mnt/c/Users/RH/Downloads/sandbox-os` |
| `C:\Users\RH\Downloads\sovereign-music-console` | `/mnt/c/Users/RH/Downloads/sovereign-music-console` |

## Requirements

- **Node 22+** in WSL (tier34 uses `node:sqlite`)
- **systemd** enabled in WSL (`/etc/wsl.conf`: `[boot] systemd=true`)

## Troubleshooting `ERR_CONNECTION_REFUSED` on :3001

| Cause | Check | Fix |
|-------|-------|-----|
| **WSL stopped** | `wsl -d Ubuntu -- echo ok` fails | `wsl -d Ubuntu` (keeps VM alive) |
| **tier34 still starting** | Service `active` but no port yet | Wait **20–40s** (slow on `/mnt/c/` repo), retry |
| **Service not running** | `sudo systemctl is-active tier34` → failed | `wsl -d Ubuntu -- sudo systemctl restart tier34` |
| **Port 3001 in use (EADDRINUSE)** | Two tier34 services fighting | Remove user unit; `sudo fuser -k 3001/tcp`; `sudo systemctl restart tier34` |

**Quick check from PowerShell:**

```powershell
.\scripts\wsl\tier34-status.ps1
```

**Manual:**

```powershell
wsl -d Ubuntu -- sudo systemctl restart tier34
Start-Sleep -Seconds 30
curl http://localhost:3001/health
```

### Keep WSL / tier34 alive (optional)

Create `%UserProfile%\.wslconfig`:

```ini
[wsl2]
vmIdleTimeout=-1
localhostForwarding=true
```

Then: `wsl --shutdown` and reopen Ubuntu.

## Next step

Create `sandbox-os-core` repo — Sandbox shell + live-build ISO recipes.
