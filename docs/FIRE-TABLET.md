# Amazon Fire tablets — adoption path (no hardware hack)

**Last updated:** 2026-07-08  
**Status:** Platform strategy — honest constraints

This doc covers what Sandbox OS can do on **consumer Amazon Fire tablets** when the user will **not** open the back, short motherboard pins, or use repair-bench hardware tricks. That constraint matches the **Activate / Spread** philosophy: one trusted device helps the next — no shop, no wiki archaeology.

**Not in scope:** ISO+QEMU PC wedge, phone Spread engineering, or Fire TV sticks (similar constraints; tablets are the mass-adoption target).

---

## Executive summary

| Question | Answer |
|----------|--------|
| Can we **replace Fire OS** with Sandbox OS on a typical Fire tablet bought today? | **No** — bootloader locked, no OEM unlock, bootrom patched on 2020+ models. |
| Can we **sideload** Sandbox stations and use Fire as a **tier34 client**? | **Yes** — ADB + unknown sources; this is the realistic v1 wedge. |
| Can **Spread** install full Sandbox OS on Fire from a Sandbox phone? | **Not today** — same bootloader wall. Future only if exploit or OEM path appears. |
| Is Fire “just Android, flash a GSI”? | **No** — Treble may be enabled, but AVB + locked bootloader blocks unsigned system images. DSU does not bypass this on stock Fire. |

**Recommended v1 wedge:** sideload **Sandbox Client** (stations + tier34 sync) on Fire OS; optional custom launcher / kiosk shell where firmware still allows it. Treat full OS replace as **future Spread catalog entry** for unlockable models only — not the household Fire HD 10 from Amazon’s sale page.

---

## Fire OS vs Android (what you are actually running)

Fire OS is a **heavily forked AOSP derivative**, not stock Android:

| Layer | Fire OS reality |
|-------|-----------------|
| **Kernel** | Linux — often MediaTek (MT8168, MT8183, MT8186A, …) on recent tablets |
| **Userspace** | Amazon services, Fire Launcher, no Google Play by default |
| **Boot chain** | Locked bootloader; **no** `fastboot oem unlock` / `fastboot flashing unlock` (those are Pixel/OEM paths, not Amazon) |
| **Updates** | Amazon OTA; can patch or **blow fuses** that disable bootrom exploits on older units |
| **Treble** | Many recent models report `ro.treble.enabled=true` — useful **only** if bootloader unlock exists |

Sandbox OS goal on phones is **replace the Android userspace** (see [PLATFORM-AND-KERNEL.md](./PLATFORM-AND-KERNEL.md)). On locked Fire tablets that replacement is **blocked at the bootloader** — you stay inside Fire OS’s app sandbox unless an exploit or OEM deal changes the chain.

---

## What Fire allows WITHOUT opening hardware

These are **stock settings** — no back removal, no test-point shorting.

### Developer options + ADB

1. **Settings → Device Options → About Fire Tablet** → tap **Serial Number** seven times.  
2. **Settings → Device Options → Developer Options** → enable **USB debugging** (Fire OS 7+: “USB debugging”; older: “Enable ADB”).  
3. Connect USB (MTP / File Transfer mode per [Amazon’s ADB guide](https://developer.amazon.com/docs/fire-tablets/connecting-adb-to-device.html)).  
4. Accept the **Allow USB debugging** prompt on the tablet.

**ADB over Wi‑Fi** works on the same LAN (`adb connect <tablet-ip>`) once USB pairing is done — same pattern as Fire TV developer docs. Useful for household Spread/sideload without keeping a cable attached.

### Sideloading (“apps from unknown sources”)

- **Settings → Security & Privacy** (or **Applications → Apps from Unknown Sources** on older builds) → allow installs for a specific browser or file manager.  
- Install APKs from trusted sources (not the Amazon Appstore).  
- **Fire Toolbox** (Windows/Linux host tool) automates sideload, Play Store install, launcher swap, and backup over ADB — still **inside Fire OS**, not OS replace ([Liliputing overview](https://liliputing.com/hack-your-amazon-fire-tablet-with-fire-toolbox-v10/)).

### Custom launcher (partial “feels like Sandbox”)

On **Fire OS 7 / 8** with compatible firmware, community tools can set a **third-party launcher** as default (Nova, Lawnchair, etc.) via temporary **system user** privilege — **not root**, **not bootloader unlock** ([XDA system-user thread](https://xdaforums.com/t/system-user-fire-cube-stick-tv-tablet-ps7704-fireos7-rs8149-fireos8.4759215/)).

**Constraints:**

- Privilege is **temporary per session**; changes made (launcher install, OTA block) **persist** until factory reset.  
- **Not** full OS replace — Amazon services and kernel remain.  
- Amazon **patched** the underlying exploit in **Fire OS 8.3.3.8+**; older builds work until OTA. Do not plan product flows that depend on a specific exploit revision.  
- A Sandbox **kiosk launcher** APK is the product-shaped version of this — default home = station grid, still on Fire OS.

### What you cannot do (without hardware or exploit)

| Action | Blocked by |
|--------|------------|
| Permanent custom ROM / Lineage / Sandbox OS image | Locked bootloader + verified boot |
| `fastboot flash system` with unsigned image | No unlock; no trusted fastboot on consumer path |
| DSU / GSI trial of Sandbox OS | GSIs must be OEM/Google-signed; DSU on locked devices still fails for third-party OS ([Android DSU docs](https://developer.android.com/topic/dsu), [XDA GSI-on-Fire thread](https://xdaforums.com/t/with-the-newer-gen-fire-tablet-with-android-9-installed-is-it-possible-to-flash-aosp-gsi-builds.4260067/)) |
| Spread-style **full partition flash** from Sandbox phone | Same bootloader wall as Lineage |

---

## Bootloader unlock — model honesty

Amazon **does not offer** a consumer bootloader unlock program. Unlock on older Fires relied on **MediaTek bootrom exploits** (amonet, mtkclient, kamakiri) — software on a Linux host, often after intentional “soft brick” steps. That is **not** Activate/Spread UX and often **requires hardware** on anything but very old firmware.

### Rough model matrix

| Device | Codename / gen | Bootloader unlock (consumer, no back open) | Notes |
|--------|----------------|-----------------------------------------------|-------|
| **Fire 7 (2019)** | mustang, 9th gen | **Only** on Fire OS **≤ 6.3.1.2** via software + amonet | Newer firmware → hardware shorting ([XDA mustang guide](https://xdaforums.com/t/fire-7-2019-mustang-unbrick-downgrade-unlock-root.3944365/)) |
| **Fire HD 8 (2018)** | karnak, 8th gen | Possible on **old** firmware via amonet; patched on many OTAs | Opening back still common in guides for failed soft steps |
| **Fire HD 10 (2019)** | douglas / mataba | Temporary unlock via patched preloader + PC each boot — **not** Spread-grade | Expert-only; PC required every reboot for some paths |
| **Fire 7 / HD 7 (2022)** | ariel | amonet only if bootloader **< 5.3.1.0** | Newer stock → script fails ([XDA ariel thread](https://xdaforums.com/t/unlock-root-twrp-unbrick-fire-hd7-hd6-ariel.4679761/)) |
| **Fire HD 10 (2021)** | e.g. PRSLA / 11th gen | **Practically no** — bootrom disabled / fused | ([XDA 2021 brainstorming](https://xdaforums.com/t/fire-hd-10-11th-generation-2021-bootloader-unlock-root-brainstorming.4509197/)) |
| **Fire HD 10 (2023)** | kftuwi / tungsten | **No known method** | MT8186A; bootrom patched ([XDA 2023 thread](https://xdaforums.com/t/fire-hd-10-13th-generation-2023-tungsten-kftuwi-bootloader-unlock-root-brainstorming.4686124/)) |
| **Fire Max 11 (2023)** | kale | **No** — Treble yes, unlock no | DSU UI may appear; GSI boot still blocked ([XDA Max 11 thread](https://xdaforums.com/t/what-are-the-possibilities-with-the-amazon-fire-max-11-2023-release.4605167/)) |
| **Fire HD 8 / HD 10 (2020+)** | various | **No** general unlock | XDA consensus: 2020+ consumer path dead without new exploit |

**Product rule:** Spread Catalog for Fire must be **per-model, per-firmware**, same as phones — default answer for **new retail inventory** is **unsupported for full OS Spread**.

---

## DSU / GSI — does it help?

**Short answer: no** for Sandbox OS on locked Fire tablets today.

- Many Fires are **Treble-enabled** — a GSI *might* match the vendor interface **if** you could flash and boot it.  
- **Verified boot** requires signatures Amazon (or MTK chain) trusts. Unsigned Sandbox images do not boot.  
- **DSU Loader** (Android 11+ developer option) installs a **guest** GSI in a dynamic partition — still requires compatible signing and OEM enablement; on Fire it does not provide a consumer path to permanent Sandbox OS ([XDA DSU on Max 11](https://xdaforums.com/t/what-are-the-possibilities-with-the-amazon-fire-max-11-2023-release.4605167/page-2)).  
- **Sticky DSU** leaves two OS slots but does not remove Amazon’s boot policy — not a Hydra-grade install.

DSU remains relevant **only after** a model gains bootloader unlock (same as [ONBOARDING-BUILDING-BLOCKS.md](./ONBOARDING-BUILDING-BLOCKS.md) DSU row for Pixels) — for Fire, that is a **research tail**, not v1.

---

## Adoption paths ranked (simplest first)

Aligned with [INSTALL-AND-ADOPTION.md](./INSTALL-AND-ADOPTION.md) — only **Activate** and **Spread** as user verbs; internal engineering may use “sideload wedge” until Spread ships.

```text
1. Activate     OEM / partner tablet ships with Sandbox OS preloaded
2. Spread       Sandbox phone → target device full OS install
3. Sideload     Sandbox Client APK (+ optional kiosk launcher) on Fire OS
4. NOT VIABLE   Full OS replace on locked 2020+ Fire without exploit or hardware
```

### 1. Activate (best — not available yet)

Factory or regional OEM ships Fire-class hardware with **Sandbox OS preloaded**. User verb: turn on, set up. Same as phone Activate in the adoption ladder.

**Reality:** Requires Amazon partnership or alternate hardware vendor — Amazon is unlikely to ship Sandbox on retail Fire. Treat as **long-term** or **Fire-form-factor clone** (same price band, unlockable bootloader).

### 2. Spread (full OS — future, narrow catalog)

When Spread Host exists ([SPREAD-PHONE-TO-PHONE.md](./SPREAD-PHONE-TO-PHONE.md)):

| Target Fire state | Spread behavior |
|-------------------|-----------------|
| **Unlockable** old model + pinned firmware | Same as Android phone: backup → unlock → flash signed Sandbox image → restore |
| **Locked** 2020+ retail Fire | Host shows **“This tablet isn’t ready yet”** — refuse flash |
| **Locked** but ADB on | Host may offer **“Install Sandbox apps”** (sideload bundle) — **not** OS Spread |

Hydra still applies: a Spread-upgraded **unlockable** tablet becomes a new head. A sideload-only Fire becomes a **client head** — syncs with tier34, cannot Spread OS to others until full install is possible.

### 3. Sideload wedge (v1 — do this)

**User story (no jargon):** On your Sandbox phone or PC: **“Add this tablet to your home”** → enable debugging once → approve prompt → Sandbox stations appear.

**Engineering:**

| Piece | Role on Fire |
|-------|----------------|
| **Sandbox Client APK** | Stations (Music, Browser, Social, …), keys, tier34 sync |
| **Sandbox Launcher** (optional) | Kiosk home — station grid replaces Fire Launcher where launcher swap works |
| **ADB / Wi‑Fi ADB** | Install + updates from Spread Host or tier34 LAN |
| **Device admin / lock task** (optional) | Kid/household kiosk — pin Sandbox shell |

**What the user keeps:** Fire OS underneath (Amazon updates, battery, drivers). **What they get:** household locker, social, music — **no Amazon account required** for Sandbox stations if designed that way.

**What they do not get:** kernel-level privacy guarantees of full Sandbox OS, no Amazon telemetry at OS level, no Spread-of-full-OS to the next Fire.

This is the same **Lane A wedge** pattern as Capacitor/PWA stations on Android today ([PLATFORM-AND-KERNEL.md](./PLATFORM-AND-KERNEL.md)) — honest interim, not the end state.

### 4. NOT viable (do not document as easy)

| Fantasy | Reality |
|---------|---------|
| “Download Sandbox ISO for Fire” | No UEFI PC; ARM tablet needs signed boot chain |
| “Same as flashing Lineage” | Lineage on Fire needed amonet + Linux + often hardware — never mass market |
| “DSU try Sandbox” | Locked + unsigned = no boot |
| “Fire Toolbox = OS replace” | Toolbox explicitly does **not** replace Fire OS |

---

## How this fits Hydra / Spread (no repair shop)

```text
  [ Sandbox PC / phone — full OS ]
              │
              ├── Spread (USB/Wi‑Fi) ──► unlockable Android phone  → full OS ✓
              │
              ├── Spread sideload mode ──► locked Fire tablet (ADB)  → Client APK ✓
              │
              └── (future) Spread ──────► unlockable old Fire only  → full OS ◐
```

| Hydra head type | Can Spread to next device? |
|-----------------|----------------------------|
| Sandbox PC / phone (full OS) | Yes — per Spread matrix |
| Fire tablet (sideload client only) | **No** full OS Spread; can **sideload** Sandbox to another Fire on same LAN/USB |
| Fire tablet (unlocked + Sandbox OS — rare) | Yes — same as phone |

**No back removal:** Spread sideload mode uses **only** developer options + USB/Wi‑Fi ADB — the same surface Amazon documents for app developers.

---

## Fear killers (Fire-specific)

| Fear | Answer |
|------|--------|
| “Will I brick it?” | Sideload wedge does not touch bootloader; uninstall APK / factory reset restores stock Fire |
| “Amazon will break it” | Pin OTA only via fragile exploits — prefer **client app** that survives normal OTAs |
| “Is this real Sandbox?” | Honest: **client on Fire OS** until Spread catalog supports that model for full OS |
| “Kids’ Fire tablet?” | Kiosk launcher + lock task; household tier34 — good v1 use case |

---

## Recommended roadmap

| Phase | Fire tablet work |
|-------|------------------|
| **Now (docs)** | This file; no ISO dependency |
| **v1 wedge** | Sandbox Client APK; tier34 pairing; ADB install script / future Spread sideload mode |
| **v1.1** | Sandbox Launcher kiosk; household “Add tablet” UX |
| **v2** | Spread Host detects Fire → sideload bundle automatically |
| **v3+** | If exploit or OEM: add **specific** models to Spread Catalog for **full OS** |
| **Parallel** | Do not block PC ISO / phone Spread on Fire work — different adoption lane |

---

## Open questions

1. Minimum Fire OS version for Sandbox Client — Android 9+ (Fire OS 7) baseline?  
2. Ship universal `armeabi-v7a` + `arm64-v8a` APK or Fire-specific build per SoC?  
3. Kids / FreeTime profile — separate kiosk policy?  
4. Partner with **non-Amazon** unlockable tablets in Fire price band instead of fighting Amazon boot chain?  
5. Track XDA / MTKclient for **one** reference unlockable Fire for Spread soak tests — which model/firmware pin?

---

## See also

- [INSTALL-AND-ADOPTION.md](./INSTALL-AND-ADOPTION.md) — Hydra, Activate/Spread verbs  
- [SPREAD-PHONE-TO-PHONE.md](./SPREAD-PHONE-TO-PHONE.md) — full OS Spread (phones first)  
- [PLATFORM-AND-KERNEL.md](./PLATFORM-AND-KERNEL.md) — why phone = OS replace, not APK forever  
- [ONBOARDING-BUILDING-BLOCKS.md](./ONBOARDING-BUILDING-BLOCKS.md) — ADB, Treble, DSU building blocks  
- [GETTING-STARTED.md](./GETTING-STARTED.md) — PC-first build order (unchanged by Fire doc)

## External references (research)

- [Amazon — Connect ADB to Fire tablet](https://developer.amazon.com/docs/fire-tablets/connecting-adb-to-device.html)  
- [XDA — Fire HD 10 2023 unlock brainstorming](https://xdaforums.com/t/fire-hd-10-13th-generation-2023-tungsten-kftuwi-bootloader-unlock-root-brainstorming.4686124/)  
- [XDA — Fire HD 10 2021 unlock brainstorming](https://xdaforums.com/t/fire-hd-10-11th-generation-2021-bootloader-unlock-root-brainstorming.4509197/)  
- [XDA — Fire 7 2019 mustang unlock](https://xdaforums.com/t/fire-7-2019-mustang-unbrick-downgrade-unlock-root.3944365/)  
- [XDA — System user (Fire OS 7/8) — launcher, not ROM](https://xdaforums.com/t/system-user-fire-cube-stick-tv-tablet-ps7704-fireos7-rs8149-fireos8.4759215/)
