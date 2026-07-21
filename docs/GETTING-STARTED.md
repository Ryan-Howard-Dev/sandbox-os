# How to begin — Sandbox vs Android origins

**Last updated:** 2026-07-07  
**Status:** Founder start guide

## What Google / Android actually started with

Android did **not** start from Ubuntu or Debian. They also did **not** write a kernel from scratch.

| Layer | What Android did (2003–2008) |
|-------|----------------------------|
| **Kernel** | **Linux 2.6** — forked and patched per device with OEM/BSP drivers |
| **Userspace** | **Built new** — Bionic libc (not glibc), custom `init`, no GNU desktop |
| **Runtime** | **Dalvik** VM → later ART (run Java/Kotlin apps) |
| **Graphics** | **SurfaceFlinger** + later HWComposer HAL |
| **Hardware** | **HAL** — OEMs plug Wi‑Fi/modem/GPU without touching core OS |
| **Apps** | SDK + later Play Store |
| **First ship** | **HTC Dream (G1)** — 2008, one phone, one carrier partner |
| **Money / alliance** | Google acquisition 2005; **Open Handset Alliance** 2007; huge team |

**Timeline:** ~5 years from company founding to first consumer phone, with Google money and OEM deals.

**Lesson for Sandbox:** They took **Linux kernel only**, built **their own userspace story**, shipped **one device** before scaling. They did **not** support every phone on day one.

---

## Sandbox vs Android (strategy comparison)

| | Android (2008) | Sandbox (sensible start) |
|---|----------------|--------------------------|
| Kernel | Linux (vendor forks) | **Linux mainline via distro** (PC first) |
| Userspace | Custom mobile stack | **Custom shell + stations** on Wayland |
| App model | Play Store + APK | **Built-in stations** + Builder |
| Identity | Google account | **Keys** + tier34 |
| First target | One HTC phone | **Your PC** → one Pixel class phone |
| Distribution | OEM preload | **Spread** + OEM later |
| Team | Hundreds | Solo / small — **borrow distro plumbing** |

Sandbox **does not** need to rebuild Bionic/Dalvik on day one. Borrow distro on PC; phone path can reuse **Treble/GSI** ideas later instead of becoming Google.

---

## How to begin (concrete steps)

### Step 0 — Freeze scope (this week)

One sentence for Phase 1:

> **Sandbox OS 0.1 = I boot Linux on my PC daily, Sandbox shell, keys, tier34, browser + one station.**

Not phones. Not Spread. Not Ghost Max. **One loop.**

---

### Step 1 — Daily-driver Linux base (week 1–2)

| Action | Why |
|--------|-----|
| Install **Debian 12** or **Ubuntu 24.04 LTS** on your main PC (dual-boot OK) | Learn what “plumbing” feels like |
| Note what you **hate** (GNOME? snaps?) | Informs Sandbox shell |
| Run **tier34** on same machine or Pi | Server story lives |

**Deliverable:** You live in Linux daily. List 10 things Sandbox shell must replace.

---

### Step 2 — Sandbox shell prototype (month 1–2)

Build **the home screen** — not the kernel.

| Piece | Start with |
|-------|------------|
| Compositor | **Wayland** — labwc, sway, or COSMIC (pick one, don’t write compositor) |
| Shell | Station launcher grid + settings + system tray |
| Identity | Ed25519 keys (reuse patterns from Conduit/Music) |
| Browser station | Firefox ESR or Chromium **without** Google sync |
| tier34 client | Health, locker sync stub |

**Repo:** new `sandbox-os-core` or `os-core` when ready — **first code repo for OS**, separate from `sandbox-os` docs.

**Created:** `C:\Users\RH\Downloads\sandbox-os-core` (2026-07-07) — shell stub, `server/health-check.mjs`, `image/build-iso.sh` skeleton.

**Updated same day:** labwc launcher (`shell/launcher/`), `PLATFORM-API.md`, tier34 platform routes (`/api/social/outbox`, messages, marketplace).

**Deliverable:** Log in → Sandbox home → open browser → tier34 connected.

---

### Step 3 — Bootable Sandbox ISO (month 2–4)

| Action | Why |
|--------|-----|
| Use **live-build** (Debian) or **Cubic** (Ubuntu) or **Fedora kickstart** | Turn your shell into bootable USB |
| Replace default session with **Sandbox** | First “this is Sandbox OS” demo |
| Auto-start tier34 optional on LAN | Home server story |

**Deliverable:** USB stick → boot → Sandbox OS on any `x86_64` PC (like early Android had **one** G1, you have **one** ISO).

**Spread Host (v0):** once the ISO exists, use [sandbox-os-core/spread/README.md](../../sandbox-os-core/spread/README.md) — `spread-host.mjs list` / `check`, then `write-usb.sh` to spread to another PC.

---

### Step 4 — Pi image (month 3–5)

Same rootfs, `arm64` kernel, lighter **Sandbox Lite** stations.

**Deliverable:** tier34 in a box; Spread target later.

---

### Fire tablets (parallel track — docs only until client APK)

Retail Amazon Fire tablets **cannot** receive full Sandbox OS without bootloader unlock (not available on 2020+ models). Realistic path: **sideload Sandbox Client** over ADB — no back removal. See [FIRE-TABLET.md](./FIRE-TABLET.md). Does not block PC ISO work.

---

### Step 5 — Phone OS 0.1 (month 4–8)

Android path for **one model** only:

| Action | Why |
|--------|-----|
| Pick **one** unlockable reference (often Pixel) | Spread Catalog #1 |
| Start from **mainline + postmarketOS** learnings or **GSI + vendor kernel** | Don’t port 50 phones |
| Replace launcher with Sandbox shell | Same UX as PC |
| **Spread Host/Receiver** spec → code | Hydra begins |

**Deliverable:** One phone boots Sandbox; demo Spread to identical model.

---

### Step 6 — Harden (ongoing)

Ghost Home → Circle → Profile; ostree updates; Spread soak tests.

---

## What NOT to do at the start

| Trap | Why |
|------|-----|
| Write your own kernel | Android didn’t; you shouldn’t |
| Support every phone | Android launched with **one** |
| Build Spread before shell boots | No Hydra without a head |
| Fork Debian entirely on week 1 | Use live-build; customize session |
| Phone before PC | PC is your dev bench |

---

## Repos (when code starts)

| Repo | Role |
|------|------|
| `sandbox-os` (this) | Vision, chronicle, decisions |
| `sandbox-os-core` (future) | Shell, compositor session, installer recipes |
| `sovereign-music-console` | Station: Music (other agent) |
| Music repo `tier34-server` | Sandbox Server hub |

---

## Android’s real “begin” in one line

**Linux kernel + brand-new mobile userspace + one partner phone + five years + Google money.**

## Sandbox’s realistic “begin” in one line

**Distro Linux + Sandbox shell on your PC + bootable ISO + tier34 + one phone model when PC is boring.**

---

## Open questions

1. Debian vs Ubuntu for first ISO?  
2. Which Wayland compositor base?  
3. When to split `sandbox-os-core` repo?  
4. Pixel generation for phone 0.1?
