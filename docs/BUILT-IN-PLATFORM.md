# Built-in platform — stations, not a surveillance store

**Last updated:** 2026-07-12  
**Status:** Core product definition

## What Sandbox OS is

One operating system that **feels the same** on phone, PC, Pi, and laptop: same shell, same stations, same keys, same server sync. Not a skin on Android. Not a store that watches you.

**Humans need:**

| Need | Built-in station (first-party) |
|------|--------------------------------|
| Web | **Browser** — Sandbox Browser (Conduit THE TIDE); no Firefox, no Chrome telemetry |
| Talk to people | **Social** — E2E messages, follows on *your* server |
| Email | **Mail** — native IMAP/SMTP client; optional tier34 mail server (not Proton/Gmail wrapper) |
| Music & media | **Media** — Sandbox Music (`sandbox-music`); full player, podcasts, cast, library |
| Private network | **Network / Ghost** — native WireGuard overlay; Home / Circle / Max modes (not Proton VPN wrapper) |
| Words & files | **Docs / Files** — local-first, sync optional |
| Pay & trade | **Vault** + **Marketplace** |
| Make things | **Builder** — artistic / creative freedom |
| Play games | **Steam, gaming platforms** — optional, user chooses |
| Govern community | **Vote** (later, small groups first) |

Everything above is a **station** in the OS — same identity, same locker, same event bus. Not a separate login per app. Not an algorithmic feed owned by a platform.

## No surveillance app store

| App-store world | Sandbox OS |
|-----------------|------------|
| Store sees every install, update, open | **No central install ledger** for core life |
| Telemetry on usage, clicks, time-in-app | **No OS-level telemetry** — usage is yours |
| Engagement optimization | Stations serve **you**, not advertisers |
| “Free” = you are the product | **$0 self-host** or **regional hosted** — not data harvest |

### What we are **not** banning

- **Creation** — Builder, sideload signed stations, artistic tools  
- **Steam & gaming** — user opts in; game platform’s terms apply inside that station  
- **Third-party tools** — installable without Apple/Google gatekeeper **where OS policy allows**  
- **The open web** — browser reaches anything; OS does not phone home your clicks  

We stop **platform extraction**, not human creativity.

## Is zero telemetry possible?

**Yes as an OS design choice** — with honest limits:

| Layer | Stance |
|-------|--------|
| Sandbox OS kernel/shell/stations | **No telemetry by default.** No usage analytics phoning home. Updates are signed; optional “check for updates” is explicit. |
| Your Sandbox Server (tier34) | **You** hold data you choose to sync. Not a corporate warehouse. |
| Hosted membership | Billing/support metadata only — not sell browsing history. |
| Third-party (Steam, a website) | **Their** policy if you use them — sandboxed; OS does not add a second spy layer. |
| Federation | Minimize metadata; E2E where possible. |

**Hard truth:** ISPs, cell towers, and websites can still see traffic unless you use overlay/VPN. Sandbox removes **OS + first-party store surveillance**, not all physics.

## Same OS across devices

**Same experience** — not one identical binary:

| Same everywhere | Varies per device |
|-----------------|-------------------|
| Shell UI, settings, station names | Kernel build (x86_64, arm64) |
| Keys, locker format, protocols | RAM-heavy stations off on 2 GB phones |
| “Move to Sandbox” flow | Drivers per phone model |
| No app store for daily life | GPU, screen size, battery policy |

One **product line**, **scaled images**: Sandbox OS / Sandbox OS Lite (budget phones, Pi).

## Relation to Android

Sandbox OS is **not** “another Android ROM” with a store removed. It is a **Linux userspace you own** — Android compatibility layer only where needed for hardware drivers (long-term engineering choice), not “stay inside Google’s world.”

Early phone images may reuse some Android HAL/driver plumbing under the hood; the **user-facing product** is Sandbox shell + stations, not Play Store + Google account.

## First-party browser

Sandbox OS does **not** ship Firefox or Chromium as the product browser.

| Layer | Choice |
|-------|--------|
| OS browser station | **sandbox-conduit** — THE TIDE (tabs, search, Ghost/Defense routing) |
| Engine | Tauri WebView2 (Windows) / WebKitGTK (Linux) |
| ISO | No `firefox-esr` long-term; launcher does not auto-open a third-party browser |

Builder (full Conduit) remains a separate **Builder** station — browser is Tide extracted for daily web use (`BrowserDashboard.tsx`, route `/tide?mode=os`).

See `sandbox-os-core/docs/STATIONS-ARCHITECTURE.md` for lazy-load boot model and station catalog.

## First-party network (VPN / Ghost)

Sandbox OS does **not** ship Proton VPN, Mullvad GUI, or any third-party VPN app as the product overlay.

| Layer | Choice |
|-------|--------|
| Tunnel | **WireGuard** — kernel/module + `sandbox-networkd` |
| UX | **Settings → Network** — Ghost: Off / Home / Circle / Max |
| Household | tier34 as default **Home** peer; Circle = friend relays (Hydra) |
| Advanced | Split stream, padding, Ghost Profile — [NETWORK-OVERLAY-GHOST.md](./NETWORK-OVERLAY-GHOST.md) |

Spec: [BUILT-IN-VPN.md](./BUILT-IN-VPN.md).

## First-party mail

Sandbox OS does **not** ship Gmail or Proton Mail as a WebView wrapper.

| Layer | Choice |
|-------|--------|
| Client | **Sandbox Mail** — IMAP/SMTP station (`sandbox-mail`) |
| Credentials | **Sandbox Vault** — not per-app password silos |
| Server (optional) | tier34 mail module — household `@home` address (v1+) |
| E2E | OpenPGP / Autocrypt where supported (v1+) |

Spec: [BUILT-IN-MAIL.md](./BUILT-IN-MAIL.md).

## Open questions

1. Android app compatibility layer — yes/no/later for banking apps?  
2. Docs station — fork LibreOffice vs lightweight native editor?  
3. How Builder-signed third-party stations install without becoming a spy store?
