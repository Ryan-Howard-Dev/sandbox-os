# Install & mass adoption — Spread like a hydra

**Last updated:** 2026-07-07  
**Status:** Product strategy — the hard problem

## The Hydra philosophy

> Cut one head off, two more grow back. That’s always been the Sandbox philosophy.

Central platforms die when you kill the server. Sandbox **multiplies at the edge**:

- One person gets Sandbox → **Spreads** to a friend’s phone  
- That phone **Spreads** to a household PC  
- That PC **Spreads** to a sibling’s Pi  
- No app store approval. No shop franchise. No single throat to choke.

**Hydra** is not a hack — it is the adoption model. Distribution **is** the product network. Every device is a seed.

| Central platform | Sandbox Hydra |
|------------------|---------------|
| Kill the company → users stranded | No single head — users **are** the distribution |
| Install via store gatekeeper | **Spread** from device you already trust |
| Growth = marketing budget | Growth = **each happy household** |
| “Go to a shop” / refurb channel | Optional backup — **not the vision** |

## What you are building

A **platform replacement** — same OS for daily human life, no surveillance store, no telemetry harvest. Mass adoption means a person with **one** Sandbox device can bring **everyone and everything** they care about over **without shops, wikis, or fastboot**.

Repair benches and refurb are **optional accelerants**, not the strategy — **Hydra is**. The strategy is:

> **Any Sandbox device can install Sandbox on the next device. Cut one head off, two grow back.**

## The only verbs users learn

| Verb | Meaning |
|------|---------|
| **Activate** | Device already has Sandbox OS — turn on, set up |
| **Spread** | This Sandbox device installs Sandbox on another device (USB, Wi‑Fi, or tap) |

No third verb. No “find a shop.” No “learn Lineage.”

## Spread — how it works (product design)

```text
  [ Sandbox phone you already use ]
              │
              ├── USB-C ──► another phone (Android)     → Spread
              ├── USB-C ──► laptop / PC (Windows…)      → Spread  
              ├── USB-C ──► Chromebook (supported models)→ Spread
              ├── Wi‑Fi ──► TV / Pi / second PC         → Spread
              └── Tap/NFC ─► friend’s phone               → Spread
```

**User sees:** “Spread Sandbox to this device?” → **Yes** → progress bar → “Done.”

**Phone → phone detail:** [SPREAD-PHONE-TO-PHONE.md](./SPREAD-PHONE-TO-PHONE.md)

**System does invisibly:** detect hardware, unlock where allowed, write image, migrate photos/contacts/docs, reboot, first-boot wizard, 24h rollback offer.

Your Sandbox phone is the **installer, migration assistant, and trust anchor** — like Apple uses one iPhone to set up another, except you are replacing the OS on the *target*, not just copying settings.

## USB Spread matrix (honest)

| Target | Spread from Sandbox phone? | Reality |
|--------|----------------------------|---------|
| **Android phone** (unlockable) | **Yes — core path** | Replace OS or dual-boot; migration built-in |
| **Windows PC / laptop** | **Yes — with reboot** | Phone provides signed installer; PC reboots into Sandbox install (USB gadget or network). User clicks once. Secure Boot may need one-time disable — explain in plain English. |
| **Chromebook** | **Partial** | Many models lock verified boot; Spread works on **supported list** only. Same as Google recovery — not every SKU. |
| **Mac (Apple Silicon / Intel)** | **Hard / limited** | Apple firmware fights non-macOS installs; not a mass Spread target early. |
| **iPhone / iPad** | **No** | Apple cryptographically blocks replacing iOS. No honest mass-adoption path. Spread can **migrate data off** iPhone toward Sandbox Android/PC — not install OS on the iPhone itself. |
| **Another Sandbox phone** | **Yes** | Tap/USB; clone identity optional, migrate always |
| **Raspberry Pi / old PC** | **Yes** | USB or SD image via Spread |
| **Amazon Fire tablet** | **Sideload only (v1)** | Bootloader locked on 2020+ retail models — **no** full OS Spread without exploit. **Sandbox Client** via ADB/Wi‑Fi is the wedge. See [FIRE-TABLET.md](./FIRE-TABLET.md). |

**Do not promise** “Sandbox phone installs OS on iPhone.” That fights Apple’s boot chain and law in many regions.

**Do not promise** “Spread replaces Fire OS on a normal Fire HD 10 from Amazon.” Same boot-chain reality as iPhone for full OS — sideload client is honest v1.

**Do promise** “One Sandbox phone spreads to your household’s Android phones and PCs.”

## Why refurb / shops are not the main story

| Approach | Scale |
|----------|-------|
| “Go to a shop” | One bench, one city — **one head** — easy to kill or ignore |
| **Hydra / Spread** | Every user is a new head — **exponential**, no gatekeeper |

Shops help where USB PCs are rare — a spare head, not the body.

OEM preload (new phones ship with Sandbox) plants the **first head** at factory scale — then Hydra takes over.

## Same OS everywhere (adoption angle)

People adopt when the **second device feels identical** to the first:

- Same home screen, stations, browser, social, docs  
- Same “Spread Sandbox” button in settings  
- Same keys — household sync via tier34  
- **Lite** image on cheap phone, **full** on PC — same names, same data, lighter GPU/RAM use  

Not 400 ROM variants. **One product**, scaled.

## Built-in life — why people switch

See [BUILT-IN-PLATFORM.md](./BUILT-IN-PLATFORM.md). People don’t switch for ideology alone. They switch when:

- Browser, social, music, docs **already there** — no store permission dance  
- **Nothing phones home** about what they open  
- Steam/games still work when they want  
- Spread doesn’t lose photos  

## Why Lineage / Graphene fail gen pop

They require **you** to become the IT department. Spread requires **one friend** or **one device** already on Sandbox.

## Steve Jobs lesson (your level)

Jobs sold **completion + zero fear**, not icons:

| Insight | Sandbox |
|---------|---------|
| Product must be whole | Built-in stations for normal life |
| Install invisible | Activate (OEM) or Spread (one tap) |
| Ecosystem lock-in | Household Spread + tier34 sync — **your** network, not Apple’s |
| Premium tax | Regional hosted / $0 self-host — not luxury hardware margin |

## Adoption ladder

```text
1. Prove OS boots (you, demos)
2. Spread v1 — Sandbox phone → one Android model + one Windows PC, migration + rollback
3. Spread v2 — Wi‑Fi to Pi, NFC phone-to-phone, Chromebook subset
4. OEM Activate — new devices ship with Sandbox (global scale)
```

## Fear killers

| Fear | Spread answer |
|------|----------------|
| “I’ll lose photos” | Migration before erase; visible checklist |
| “I’ll brick it” | Supported-device list only; rollback partition |
| “Too technical” | One button; phone does the rest |
| “iPhone friends?” | Honest: iPhone stays iOS; Spread **from** iPhone data **to** Sandbox Android/PC |
| “No apps I need” | Built-in stations + Steam; no spy store for daily life |

## Why many women prefer iPhone (product lesson, not destiny)

Sandbox can learn from what Apple **solved emotionally** without copying surveillance:

| Factor | What people report | Sandbox response |
|--------|-------------------|------------------|
| **Feels simple** | Android fragmentation confused; iOS consistent | **One OS, same UI on every supported device** — no “which ROM?” |
| **Social pressure (US/UK)** | iMessage “blue bubbles,” FaceTime default | **Social station** + federation; cannot fake iMessage lock-in — compete on privacy + built-in social |
| **Privacy story** | Apple markets hard (perception > Android OEM bloat) | **Actual** no-telemetry OS, not marketing slide |
| **Camera / photos** | iPhone praised for consistency | Invest in camera station + local library |
| **No crapware** | Carrier Android full of junk | Sandbox ships clean; no preinstalled adware |
| **Support** | Apple Store genius bar | Spread + rollback + human-readable docs; hosted support tier |
| **Safety stigma** | Some associate Android with scams (varies by market) | Signed OS only; Builder stations signed; no random APK store as default |
| **Design polish** | Fit and finish read as “premium” | Polish matters — but **Spread + built-in life** beats wallpaper |

This is **market research**, not “women are X.” Many men prefer iPhone too for the same reasons. The pattern is: **fear of breaking things + social fit + it just works**. Spread targets the first; built-in social targets the second; built-in stations target the third.

## Open questions

1. Spread v1 reference targets: Pixel phone + which Windows path?  
2. Phone-as-USB-installer: gadget mode vs companion app on borrowed PC (hidden)?  
3. iPhone **data export** during Spread-to-Android — legal APIs only (Move to iOS reverse)?  
4. Chromebook supported SKU list — partner with Google recovery model or own?  
5. Dual-partition rollback retention — 7, 14, or 30 days?
