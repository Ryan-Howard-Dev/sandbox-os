# Spread onboarding — what exists to build on

**Last updated:** 2026-07-07  
**Status:** Engineering inventory + stability requirements

This doc answers: **what is already in place to use**, and **what makes Spread stable, smooth, and dumb-simple** for every human — not whether Sandbox has shipped it.

---

## What you can use today (building blocks)

### Phone ↔ phone over cable / air

| Building block | Status | Use in Spread |
|----------------|--------|---------------|
| **USB-C OTG** | Standard on modern Android | Source phone = USB **host**; target = device |
| **ADB / fastboot over USB** | Mature, documented | Hidden behind Spread daemon — user never types commands |
| **USB Gadget (configfs)** | Linux kernel | Source presents MTP / custom **Spread Protocol** endpoint |
| **Wi‑Fi Direct / Aware** | Widely available | Cable-free image transfer (v1.1) |
| **NFC NDEF** | Common on mid+ phones | Tap → pair → hand off bulk to Wi‑Fi/USB |

### Android install & rollback

| Building block | Status | Use in Spread |
|----------------|--------|---------------|
| **A/B partitions** | Most phones since ~2017 | Flash slot B while A runs; rollback = switch slot |
| **Dynamic partitions** | Android 10+ | Resize logical partitions during flash |
| **AVB (verified boot)** | Standard | Only Sandbox-signed images boot |
| **Treble / GSI** | Qualcomm/MediaTek reference | Widen device coverage with one image + overlays |
| **DSU (Dynamic System Updates)** | Pixel / dev | Prototype **trial boot** before permanent Spread |
| **OEM unlock API** | Varies by OEM | Automate where `ro.oem_unlock_allowed=1` |

### Data migration (before erase)

| Building block | Status | Use in Spread |
|----------------|--------|---------------|
| **MediaStore / ContactsProvider / SMS backup APIs** | Android standard | Export to encrypted blob on Spread Host |
| **SAF (Storage Access Framework)** | Android | User-granted folder backup |
| **Smart Switch–class UX patterns** | Samsung/Google shipped | Copy interaction model, not spyware |
| **libimobiledevice** | Open source | Export **from** iPhone **to** Sandbox target (not install on iPhone) |

### OS image delivery & stability

| Building block | Status | Use in Spread |
|----------------|--------|---------------|
| **erofs / squashfs** | Linux | Small compressed read-only OS images |
| **zchunk / casync / rsync deltas** | Open source | Resume interrupted transfer; don’t re-send 3 GB |
| **ostree / rauc / Mender** | Production-grade | OTA updates **after** install — stay stable |
| **dm-verity / fsverity** | Kernel | Tamper-evident system partition |
| **Ed25519 signatures** | Sandbox identity stack | Image + catalog signing |

### PC / Pi Spread (same Hydra, different target)

| Building block | Status | Use in Spread |
|----------------|--------|---------------|
| **UEFI + USB boot** | Standard PCs | Phone as USB mass storage or PXE gadget |
| **Calamares / Debian installer** | Mature | Adapt to “Spread from phone” boot path |
| **Raspberry Pi Imager protocol** | Proven | Model for phone → SD card → Pi |

### Network / household (post-onboard)

| Building block | Status | Use in Spread |
|----------------|--------|---------------|
| **mDNS** | Conduit already uses | Find home tier34 on LAN |
| **Headscale / Tailscale / Nebula** | Self-hostable overlay | Reach household server without Google relay |
| **WireGuard** | Kernel | Encrypted device ↔ server |

**None of these are Spread.** They are **parts on the shelf**. Spread is the glue + UX + signing + catalog + migration order.

---

## What makes Spread stable (engineering requirements)

| Requirement | How |
|-------------|-----|
| **Never brick** | Spread Catalog = supported models only; refuse unknown IDs |
| **Backup before wipe** | Strict phase order; abort if backup fails |
| **Atomic flash** | A/B slot: write entirely to inactive slot, verify, then switch |
| **Checksum every chunk** | zchunk/casync; resume on disconnect |
| **Signed images only** | AVB + Sandbox pubkey in receiver stub |
| **Rollback window** | Keep prior slot 24–72h; one tap “Go back” |
| **Kill bad update** | Revoke image signature; OTA won’t apply bad build |
| **Post-install OTA** | ostree/rauc — same path phones use today for stability |
| **One image per SoC family** | Treble/GSI + device overlay — not 400 bespoke ROMs |
| **Soak test matrix** | 100+ Spread cycles on reference device before catalog add |

Stability = **boring infrastructure** (A/B, signed OTAs, catalog gate), not heroics.

---

## What makes onboarding dumb-simple (UX requirements)

**Rule:** Two verbs — **Activate** / **Spread**. No third screen of jargon.

| Fear | UX answer |
|------|-----------|
| “I’ll break it” | Target always confirms on **their** screen; Host can’t flash without it |
| “I’ll lose photos” | Stage 1 visible: “Saving your photos…” — bar doesn’t pass 10% until done |
| “I don’t understand” | Stages in human words only: Photos → Installing → Finishing → Done |
| “Wrong language” | Locale on first Spread screen; voice readout optional |
| “No internet” | Image cached on Host or tier34 LAN — Spread works offline |
| “Low literacy” | Icons + video loop, no paragraph text |
| “Can’t go back” | “Go back to old phone system” button 24h, same place as Settings |
| “Wrong phone model” | “This phone isn’t ready yet” — not an error dump |
| “Takes forever” | Chunked transfer; resume; show time estimate |

**Onboarding is not install.** After reboot: 3 questions — name, language, join home server? (optional). Stations already there. No “download browser.”

---

## v1 → planet scale (order of operations)

```text
1. Pick ONE reference phone (e.g. one Pixel generation) — Spread Catalog entry
2. Build Spread Host + Receiver on that pair only — 100 soak tests
3. A/B flash + 24h rollback working on that pair
4. Migration: photos + contacts bulletproof on that pair
5. Add second SoC family (e.g. one MediaTek budget chipset for Tier D markets)
6. Wi‑Fi Direct Spread (no cable)
7. OEM preload Activate (factory plants first head — Hydra still does rest)
```

Smooth for **every human on the planet** = **same UX**, **scaled images** (Lite on 2 GB RAM), **regional price** — not **same day-one device list**.

---

## Relation to world change (honest)

Technology does **not** automatically make “one people” or end all conflict. History, resources, and ideology remain.

What a sovereign OS **can** remove or reduce:

| Nonsense driver | Sandbox lever |
|-----------------|---------------|
| Platforms profiting from outrage algorithms | Built-in social without engagement farming |
| “You need our permission to exist online” | Keys + $0 self-host |
| Data colonialism (your life in Virginia) | Locker + your tier34 |
| Surveillance as business model | No OS telemetry; no spy store |
| Central kill switch on speech/commerce | Federation + Hydra Spread — no single head |
| Expensive freedom | Regional PPP hosted |

What it **cannot** magically fix: war, religion, nationalism, scarcity — but it can **stop amplifying** them for ad revenue and **return agency** over identity, data, and trade to humans.

“Power back” in concrete terms: **your keys, your locker, your server, your stations** — not Apple’s, not Google’s, not a government’s backdoor by default.

---

## See also

- Flow: [SPREAD-PHONE-TO-PHONE.md](./SPREAD-PHONE-TO-PHONE.md)  
- Philosophy: [INSTALL-AND-ADOPTION.md](./INSTALL-AND-ADOPTION.md)  
- Built-in life after boot: [BUILT-IN-PLATFORM.md](./BUILT-IN-PLATFORM.md)
