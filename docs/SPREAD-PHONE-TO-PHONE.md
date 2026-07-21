# Spread phone → phone — how it works

**Last updated:** 2026-07-07  
**Status:** Technical design (v1 spec)

## What the human does

1. On **your** Sandbox phone: **Settings → Spread Sandbox → To another phone**  
2. Plug **USB-C to USB-C** cable (or tap NFC, then keep phones close)  
3. On **their** phone: tap **Yes, move me to Sandbox**  
4. Wait (20–40 minutes — progress bar, not terminal)  
5. Their phone reboots into Sandbox OS; photos/contacts restored; 24h “go back” offered  

They never hear: bootloader, fastboot, ROM, hash.

---

## What happens under the hood (phases)

```text
┌─────────────────────┐         USB-C / Wi‑Fi Direct         ┌─────────────────────┐
│  SOURCE (Sandbox)   │ ◄──────────────────────────────────► │  TARGET (Android)   │
│  Spread Host        │                                      │  Spread Receiver    │
└─────────────────────┘                                      └─────────────────────┘
         │                                                              │
         │  1. Handshake + device ID                                     │
         │  2. Compatibility check (model, storage, unlock policy)       │
         │  3. Backup target user data → encrypted blob on SOURCE        │
         │  4. Unlock bootloader (if allowed, user confirmed once)       │
         │  5. Stream signed Sandbox OS image → TARGET flash partitions  │
         │  6. Verify signatures; reboot TARGET into Sandbox             │
         │  7. Restore backup into Sandbox locker / accounts             │
         │  8. Leave rollback slot (optional Android partition 24h)      │
         ▼                                                              ▼
   Hydra: TARGET is now a new head — can Spread again
```

---

## Connection methods

| Method | When | Bulk data |
|--------|------|-----------|
| **USB-C OTG** | Default — most reliable | Cable carries image + commands |
| **Wi‑Fi Direct** | No cable; same room | Source hosts hotspot; slower but works |
| **NFC tap** | Starts pairing only | Hands off to Wi‑Fi for image |

USB is v1. Wi‑Fi/NFC are v1.1 comfort.

---

## Spread Host (source — your Sandbox phone)

Built into the OS. Responsibilities:

| Job | Detail |
|-----|--------|
| **Detect target** | USB vendor/product ID → lookup in **Spread Catalog** (signed list of supported models) |
| **Serve image** | Cached **Sandbox OS Lite** or full image matching target SoC (arm64, device tree) |
| **Sign / verify** | Only official Sandbox-signed images flash; target verifies before write |
| **Orchestrate flash** | Speak **Spread Protocol** over USB (ADB/fastboot hidden behind one daemon) |
| **Hold backup** | Encrypt user data from target on source until restore completes |
| **Rollback package** | Keep previous boot image in hidden partition if dual-partition supported |

Image source on phone (2–4 GB typical):

- Pre-downloaded in **Settings → Spread → Keep install package ready**  
- Or pull from **your tier34** at home over Wi‑Fi while USB handles flash  
- Or chunked download **direct to target storage** during Spread  

---

## Spread Receiver (target — their Android phone)

Two entry paths:

### Path A — Target still running Android (most common)

1. Cable plugged in → Android shows **“Sandbox Spread”** notification (or opens receiver)  
2. Receiver is a **small signed package** delivered over USB from Host (ephemeral — not Play Store)  
3. Receiver grants **one-session** permission to: read contacts/photos for backup, reboot to flash mode  
4. User confirms with fingerprint/PIN on **their** phone  

### Path B — Target already in fastboot (power user / failed Spread)

Host detects fastboot USB ID and continues without Android receiver — still no user typing commands.

### Unsupported target

Host shows plain English: **“This model isn’t ready yet”** — not a brick attempt.

---

## Bootloader unlock (the scary step — automated)

Many Android phones require **OEM unlock** once. Spread automates where legally/technically allowed:

| Step | User sees | System does |
|------|-----------|-------------|
| Check unlock policy | “Sandbox needs permission to replace the system on **this** phone.” | Query `ro.oem_unlock_allowed` |
| Confirm | Fingerprint + **“I understand”** once | `fastboot oem unlock` (wipes data — **after** backup in step 3) |
| Flash | Progress bar | `fastboot flash` / dynamic partition updates |
| Reboot | Sandbox setup wizard | First boot |

**Order matters:** backup **before** unlock wipe. Lineage gets this wrong for humans; Spread must not.

Phones with **locked bootloader forever** (some carrier SKUs): **cannot Spread** — honest list in Spread Catalog.

---

## Data migration (why people say yes)

Before erase, Receiver exports to Host (encrypted):

| Data | Method |
|------|--------|
| Photos / video | MediaStore scan |
| Contacts | ContactsProvider |
| SMS (where OS allows) | Backup API |
| WhatsApp etc. | User-guided export where no API — honest gaps listed |
| Wi‑Fi passwords | Android backup extract if permitted |

After Sandbox boots, **Restore** imports into built-in Files / Social / Contacts station.

---

## After install — Hydra

Target phone now runs Sandbox OS. In Settings:

**Spread Sandbox → To another phone**

Same flow. One head → two heads.

Optional: **same household keys** — “Join this home’s server?” links both to tier34 without sharing passwords.

---

## Rollback (fear killer)

If target supported **dual partition** or **snapshot**:

- **24 hours:** Settings → **Go back to previous system**  
- Restores pre-Spread Android image from hidden slot  

If not supported: Host kept encrypted backup on source + cloud tier34 optional — “Restore my old photos” at minimum.

---

## Security model

| Threat | Mitigation |
|--------|------------|
| Malicious phone flashes bad image | Only Sandbox-signed images accepted; pubkey in receiver ROM stub |
| Stranger spreads without consent | Target must confirm on **target** screen + PIN |
| Stolen backup on source | Encrypted to target’s new key; wiped after restore or 7 days |
| Fake Spread Host | Mutual TLS + device attestation (signed Host identity) |

---

## v1 scope (realistic first ship)

| In v1 | Later |
|-------|-------|
| USB-C Spread | Wi‑Fi Direct |
| 1–3 phone models in Spread Catalog (e.g. one Pixel generation) | Dozens of chipsets |
| Full migrate photos + contacts | Every chat app |
| Replace Android | Dual-boot option |
| 24h rollback on supported models | Universal snapshot |

Perfect **one model** beats broken **every model**.

---

## Does Spread exist yet?

**No.** Sandbox OS is not bootable on phones yet. There is no Spread Host, no Spread Receiver, no Spread Catalog — only this spec and related docs in `sandbox-os`. Nothing to download or try.

**v1 engineering has not started** in this repo (docs-only by design).

---

## Has anyone done this before?

**The full package — no.** Not as a consumer product: phone-to-phone, full OS replace, auto migration, rollback, no PC, no fastboot vocabulary.

**Pieces exist separately:**

| Piece | Who / what | What it does | What it does **not** do |
|-------|------------|--------------|-------------------------|
| **Phone → phone data move** | Apple Quick Start, Samsung Smart Switch, Google Pixel copy | Photos, contacts, apps (sometimes) | Replace the OS |
| **Move to iOS / Move to Android** | Apple / Google | Migrate data between ecosystems | Install new OS on source phone |
| **PC + fastboot flash** | LineageOS, GrapheneOS, XDA | Full custom ROM | Requires laptop, unlock, technical user |
| **Phone as USB boot disk** | DriveDroid (Android, niche) | Boot a **PC** from image on phone | Phone-to-phone OS install |
| **Dynamic System Updates (DSU)** | Google (Pixel, dev option) | Temporarily **try** a GSI without full flash | Permanent replace + gen-pop UX |
| **A/B partitions + rollback** | Modern Android OEMs | OTA rollback after bad update | User-initiated “Spread from friend’s phone” |
| **Enterprise MDM zero-touch** | Apple, Google workspace | New device provisions from cloud | Consumer; not friend’s phone |
| **Root + OTG flash (hobbyist)** | XDA forums | One rooted phone flashes another | Fragile, model-specific, not safe for gen pop |

**Sandbox Spread would combine:**

1. Apple-quality **migration UX** (tap Yes, progress bar)  
2. Lineage-class **full OS replace** (bootloader, flash, device tree)  
3. OEM-class **rollback** (A/B or snapshot)  
4. **Phone as installer** (no laptop) — closest hobbyist analog is rooted OTG flash, never productized for normal humans  

That combination as **one button** is **novel as a product**. The primitives are known engineering; the **packaging** is not.

---

## Relation to other docs

- Philosophy: [INSTALL-AND-ADOPTION.md](./INSTALL-AND-ADOPTION.md) (Hydra)  
- Kernel/images: [PLATFORM-AND-KERNEL.md](./PLATFORM-AND-KERNEL.md)  
- Decision: D-020, D-021 in [DECISIONS.md](./DECISIONS.md)
