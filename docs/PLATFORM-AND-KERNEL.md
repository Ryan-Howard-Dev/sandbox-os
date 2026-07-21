# Platform & kernel — Sandbox OS on every class of device

**Last updated:** 2026-07-07  
**Status:** Architecture note — not a build recipe yet

## What we are building

**Sandbox OS** — a bootable operating environment on PC, Pi, and phone. Stations (Music, Builder, Social, …) run **inside the OS shell**, not as apps rented from Apple or Google.

The Music repo’s Capacitor/PWA builds are **station development prototypes** while the OS is not bootable on phones yet. They are **not** the phone strategy and **not** the end state.

## Short answer on kernels

- There is **one Linux kernel project** (one source tree).  
- There is **not** one kernel binary that boots on every device without per-device work.  
- Sandbox OS uses **Linux** everywhere — same family, **different builds** per CPU and per phone model (device tree, drivers, bootloader).

That is normal. Android ships thousands of kernel builds under the hood. Sandbox OS will do the same — except **you** own the userspace, shell, and stations.

## Do all Linux kernels “start the same”?

**At the source level — yes.** The [Linux kernel](https://kernel.org) is a single codebase. You configure and compile it per:

| Dimension | Examples |
|-----------|----------|
| **CPU architecture** | `x86_64` (PCs), `arm64` (modern phones, Pi 4+), `armv7` (older Pi, legacy phones) |
| **Device tree / drivers** | Wi‑Fi, GPU, modem, battery, display — every phone model |
| **Features** | Size-optimized for low RAM, hardening, power management |

A PC kernel image does not boot on a Tecno phone until that phone’s **bootloader chain + drivers + device tree** are in the build.

## Sandbox OS by device class

| Device class | Sandbox OS path | Kernel |
|--------------|-----------------|--------|
| **Desktop / laptop** | Installer or live image — Sandbox shell replaces desktop session | Linux `x86_64`, distro LTS base |
| **Raspberry Pi / SBC** | Same OS lineage, lighter default stations; can run home tier34 | Linux `arm64` / `armv7` |
| **Phones (flagship → budget)** | **Sandbox OS phone image** — flash or OEM preload; Sandbox shell is the home screen | Linux `arm64` per device family |
| **Low-end phones (Nigeria, India, …)** | **Same goal: Sandbox OS installed** — lean image, offline locker, Tier D hosted pricing | Same — porting program, not a separate “app tier” |

**There is no permanent “phone = stay on Android and ship an APK” plan.**

## Phone OS — how it works technically

Phones already run a Linux kernel today (inside Android). Sandbox OS **replaces the Android userspace** (or ships a mainline-Linux mobile stack) with:

- Sandbox shell (station launcher, settings, identity)  
- Stations as OS modules — not Play Store apps  
- tier34 client built in  
- No Google account required for core use  

### Porting strategy (honest, OS-first)

| Approach | Role |
|----------|------|
| **Device porting matrix** | Start with a small set of chipsets (e.g. common MediaTek, Qualcomm, Unisoc) and popular models; expand |
| **Treble / GSI where possible** | Generic System Images boot on many unlocked Treble-compliant phones — widen reach without per-OEM apps |
| **Mainline Linux mobile** | postmarketOS, etc. — reuse driver work where it exists |
| **OEM / regional partner** | Preload Sandbox OS on new hardware sold in target markets (long-term mass reach) |

Cheap phones are **harder to port**, not **a different product category**. The freedom mission means **working toward installable Sandbox OS on budget hardware**, not telling people to keep Android.

### Constraints on budget phones (design for them)

- Low RAM (2–4 GB), small storage — lean compositor, optional stations, aggressive locker cache policy  
- Intermittent connectivity — offline-first stations  
- Battery — no surveillance background polling (aligns with [D-005](./DECISIONS.md))  
- Regional pricing — Tier **D ($1)** hosted or **$0 self-host** ([ETHICS-AND-ECONOMICS.md](./ETHICS-AND-ECONOMICS.md))

## Architecture map

```text
┌──────────────────────────────────────────────────────────┐
│                    Sandbox OS                             │
│   Linux kernel (per device build) + Sandbox userspace     │
│   shell · keys · locker · tier34 · stations               │
└──────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
    x86_64 PC            arm64 Pi              arm64 phone
   (installer)          (image)            (flash / OEM)
```

**One OS. One story. Many kernel builds.**

---

## Why not a “vanilla kernel with all drivers”?

**kernel.org gives you the kernel source — not an OS, and not all drivers in one box.**

### Kernel alone ≠ operating system

```text
What kernel.org ships          What a human actually needs to boot
─────────────────────          ─────────────────────────────────────
CPU, RAM, drivers, syscalls    Bootloader (GRUB, etc.)
                               init (systemd)
                               C library (glibc)
                               Shell, core utils
                               Firmware blobs (Wi‑Fi, GPU — separate files)
                               Display server (Wayland)
                               Your Sandbox shell + stations
                               Installer, updater, package format
```

The **kernel** talks to hardware. It does **not** draw your UI, run your browser, or install itself on a USB stick. **You** (or a distro) assemble everything above it.

### There is no universal “all drivers included” kernel

| Myth | Reality |
|------|---------|
| One vanilla build runs every PC and phone | **No** — you **select** drivers at compile time; phone needs **device tree** per model |
| All drivers are in the kernel tarball | **Many** Wi‑Fi/GPU/modem need **firmware blobs** (separate, often proprietary) from manufacturers |
| Android phone drivers work on mainline vanilla | **Often no** — vendors ship forked kernels; mainline catches up slowly |
| Bigger kernel = supports all hardware | Kernel would be huge; most drivers load as **modules** only when needed |

**Vanilla** = unmodified **mainline** source from Linus’s tree. Still **configured per device** — not plug-and-play for every machine on Earth.

### So why start from Debian / Ubuntu / Fedora?

You’re not building “their OS.” You’re **borrowing their plumbing** so you can build **yours**:

| Distro already solved | You focus on |
|----------------------|--------------|
| Compiled kernel + module set for PC | Sandbox shell |
| Firmware packages | Stations |
| Bootloader + installer | Spread |
| Security updates for kernel | Ghost overlay |
| Package format for adding tools | tier34 client |

**Sandbox OS** = **your shell + stations + rules** replacing GNOME/KDE session — not reinventing `apt`, GRUB, and ten years of driver packaging.

### If you refuse any distro flavor

| Path | Cost |
|------|------|
| **Linux From Scratch** | Months before desktop appears — educational, not product |
| **Buildroot / Yocto** | Good for **embedded** (Pi appliance); thin for full desktop + phone |
| **Raw kernel.org + assemble everything** | You become a distro maintainer **and** OS inventor — two full-time jobs |

**Later** (millions of users): custom immutable image (ostree), own update channel — still **based on** kernel builds you don’t write from zero.

### What “vanilla” can mean for Sandbox

| Stage | Kernel approach |
|-------|-----------------|
| **Start** | Distro’s kernel package (tracking mainline closely) |
| **Grow** | Sandbox kernel **config** — same mainline, your driver set per device family |
| **Mature** | Own build pipeline — still **mainline source**, not a new kernel project |

You get **vanilla philosophy** (mainline Linux, no secret sauce in the kernel) without **vanilla loneliness** (building an entire planet from one tarball).

---

## What to build first (Phase 1)

Order matches [PHASES.md](./PHASES.md) — prove daily-driver loop, then widen devices:

1. **Do not fork kernel from scratch** — use Linux + LTS distro lineage on PC.  
2. **Sandbox shell** — station launcher, settings, identity (extract from Music + Conduit patterns).  
3. **Ship `x86_64`** — your daily driver.  
4. **Add `arm64` Pi image** — home server + thin client proof.  
5. **Phone OS 0.1** — one reference device family booting Sandbox shell.  
6. **Expand porting matrix** — GSI, chipset ports, OEM conversations.  
7. **Sandbox Switch spec** — one-button migrate + flash for certified models ([INSTALL-AND-ADOPTION.md](./INSTALL-AND-ADOPTION.md)).

## Non-goals

- Permanent reliance on Android/iOS app wrappers for phones  
- Custom microkernel from scratch  
- Abandoning budget markets because porting is hard  

## Open questions

1. First phone reference target — which chipset/model for OS 0.1 phone image?  
2. LTS distro base for desktop — Debian vs Ubuntu vs Fedora?  
3. Wayland compositor — fork GNOME/KDE session vs minimal custom shell?  
4. GSI vs per-device images for Phase 2 phone rollout?  
5. Minimum RAM/CPU spec for “Sandbox OS Lite” on budget phones?
