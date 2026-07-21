# Network overlay — use their air, chase a ghost

**Last updated:** 2026-07-07  
**Status:** Architecture direction — not implemented

## Founder intent

> Can’t rebuild the global network — but it can be used **against** them. 3G/4G/5G data is in the air everywhere. Split the stream so it’s not one pipe to harvest. Wi‑Fi routers as ping hops — connect without showing the **true face** of the device. They chase a ghost.

This is the **overlay layer** of Sandbox OS: same planet-scale radios and routers; **inverted control** — user traffic is fragmented, relayed, and anonymized at the protocol level.

---

## What “ghost” means (technical)

| True face (what trackers want) | Ghost (what they get) |
|--------------------------------|------------------------|
| Device ID + SIM + IP → one person | Rotating IDs, relay hops, split paths |
| One stream → full browsing profile | Many padded streams → noise |
| Origin IP = your home | Egress IP = someone else’s relay node |
| Metadata links all apps to you | Per-session / per-relay separation |

**Not magic invisibility.** Nation-state correlation across all hops is still hard. Goal: **make mass commercial harvest and casual ISP/carrier profiling economically and technically impractical** — not “impossible against NSA.”

---

## Layer cake (where Sandbox sits)

```text
┌─────────────────────────────────────────────────────────┐
│  Stations (browser, social, music) — no OS telemetry     │
├─────────────────────────────────────────────────────────┤
│  GHOST OVERLAY — split, pad, relay, rotate IDs           │  ← this doc
├─────────────────────────────────────────────────────────┤
│  Wi‑Fi / 4G/5G / ISP — their wires and air (reused)      │
└─────────────────────────────────────────────────────────┘
```

Sandbox doesn’t replace towers or fibre. It **rides them** like Tor rides the internet — except the relay pool is **Sandbox mesh + tier34 nodes + friend Hydra heads**, not only volunteer strangers.

---

## Tactic 1 — Split the stream (cellular + paths)

**Idea:** Traffic is not one harvestable pipe from SIM → carrier → profile.

| Mechanism | Role |
|-----------|------|
| **Multipath** | Same session split across Wi‑Fi + cellular, or across **multiple relays** — no single observer sees whole flow |
| **Tunnel to relay first** | Carrier sees: encrypted blob to relay IP. Not final destination, not content |
| **Padding** | Fixed-size cells or dummy traffic — resists “this packet size = this app” fingerprinting |
| **Scheduling jitter** | Bursts don’t line up for timing correlation |

**Reality check:** Carrier **always** knows your SIM attached to **a** tower. They don’t automatically know **what** inside encrypted tunnel, or **final** destination if egress is a relay. Splitting raises bar; doesn’t erase “phone was online at 14:03.”

**Building blocks to use:** WireGuard, multipath TCP/MPTCP where available, QUIC over several paths, custom Sandbox **Split Tunnel Protocol** over UDP.

---

## Tactic 2 — Wi‑Fi as ping hops (router mesh)

**Idea:** Packets bounce across nearby Wi‑Fi paths — home routers, café, friend’s tier34, phone hotspot — each hop only knows previous and next.

| Mechanism | Role |
|-----------|------|
| **Onion / layered encryption** | Each relay peels one layer; can’t see full path |
| **LAN relay via tier34** | Your home Pi relays for household; friend’s node for federated hop |
| **mDNS / peer discovery** | Find trusted relays on LAN (Conduit already sketches mDNS) |
| **Opportunistic Wi‑Fi handoff** | Prefer hop through known Sandbox node when leaving home |

**Analogy:** Tor guard → middle → exit. Except exits can be **your federation** — people you trust, not random exit nodes mining data.

**Building blocks:** WireGuard mesh, Nebula, Headscale, I2P garlic routing concepts, BATMAN-adv for community mesh (heavy), **lighter:** Sandbox-defined relay protocol on top of WireGuard.

---

## Tactic 3 — Hide the true face (identity rotation)

**Idea:** Device doesn’t present one permanent fingerprint to every network.

| Mechanism | Role |
|-----------|------|
| **MAC randomization** | Per-network Wi‑Fi MAC (OS default) |
| **Rotating tunnel keys** | New overlay identity per session or per day |
| **Relay egress** | Websites see relay IP, not home IP |
| **Separate station network profiles** | Social vs browse vs marketplace can use different relay paths |
| **No SIM in clear for app traffic** | App traffic exits via overlay; cellular metadata reduced to “tunnel to relay” |

**Keys = you** for **your** identity with friends. **Network face** seen by ISP/carrier/sites = ghost.

---

## Tactic 5 — Ghost Profile (fake harvest they can keep)

**Founder intent:** Give trackers a **person they can profile** — but it’s a **decoy**. They think they’re harvesting; they’re filling a database with a **ghost persona** that isn’t you.

### Two layers on one device

```text
┌─────────────────────────────────────────────────────────┐
│  REAL YOU — keys, social, docs, music (encrypted path)   │  ← Ghost: Home/Circle/Max
├─────────────────────────────────────────────────────────┤
│  GHOST PROFILE — synthetic decoy (clear / bait path)     │  ← what harvesters see
├─────────────────────────────────────────────────────────┤
│  Carrier / ISP / ad-tech pipes                           │
└─────────────────────────────────────────────────────────┘
```

**Real life** rides overlay (tunnels, relays, E2E). **Ghost Profile** rides the **bait lane** — deliberate, plausible, **fake**.

### What goes into the ghost profile

| Signal harvesters want | Ghost feeds them |
|------------------------|------------------|
| Browsing interests | Scripted visits to random categories (news, sports, gardening — rotated persona) |
| Search-like DNS | Decoy DNS queries to common domains |
| App-like traffic | Padded HTTPS to CDN shapes that look like “social app,” “shopping” |
| Location hints | Egress via relay in **decoy region** (not home) |
| Device fingerprint | **Disposable browser profile** — generic hardware-ish UA, canvas noise |
| Time patterns | Background “human” schedule — morning news, evening video-shaped traffic |
| Ad IDs | **Empty or rotating** sandbox IDs — never link to real keys |

Persona is **consistent enough to believe** (one fake 42-year-old into fishing this week), **wrong enough to be useless** (not you).

### How it poisons harvest

| Effect | Why |
|--------|-----|
| **Profile pollution** | Real + fake merged → ML confidence collapses |
| **Wasted storage** | They pay to store ghost data |
| **Wrong ads / wrong sells** | Data brokers sell garbage |
| **Legal discovery noise** | If leaked, decoy ≠ truth (careful: don’t use for crime — self-defense vs commercial harvest) |

Prior art (pieces): **AdNauseam** (click all ads), **TrackThis** (persona tabs), **Mozilla dummies**, **Brave fingerprint randomization**, academic **obfuscation** / **Fog computing** traffic.

Sandbox difference: **OS-level decoy lane** — not one browser extension; **whole bait stream** while real stations never touch clear pipe.

### User control (dumb)

| Setting | Behaviour |
|---------|-----------|
| **Ghost Profile: Off** | No decoy traffic (save bandwidth) |
| **Ghost Profile: Light** | Low-volume noise — DNS + padding |
| **Ghost Profile: Full** | Active decoy persona (scheduled fake browsing) |

Default: **Light** on cellular, **Full** optional on Wi‑Fi when charging.

User never names the persona — OS picks from **rotating templates** or **random plausible human**.

### Rules (non-negotiable)

1. **Never mix** — real station traffic **never** exits bait lane. Hard network namespace separation.  
2. **Ghost never uses real keys** — separate session, no tier34, no social login.  
3. **No impersonation of real people** — synthetic personas only, not “pretend to be Bob.”  
4. **Bandwidth cap** — Tier D markets: Light default so data cost stays sane.  
5. **Honest in UI** — Settings explains: “Feeding decoy data to anyone watching the wire.”

### What ghost profile does **not** do

- Replace encryption — bait is **in addition to** overlay, not instead of  
- Fool targeted human investigation with warrants on **real** activity  
- Guarantee ad networks notice — some ignore obvious bots; goal is **bulk harvest corruption**, not perfect theatre

---

## Tactic 4 — Hydra as relay supply

Every Spread device is a potential **head** — and a potential **relay** (opt-in, battery-aware):

| Node | Can relay for |
|------|----------------|
| tier34 at home | Household always-on hop |
| Sandbox phone (charging + Wi‑Fi) | Friends in web-of-trust |
| Sandbox PC | High-bandwidth exit for trusted circle |

**Cut one head off, two grow back** applies to **surveillance too** — block one relay IP, traffic routes through another friend’s tier34.

Not every phone is a public exit (abuse, law, battery). **Web-of-trust relays** — federated taste graph extended to **network graph**.

---

## What this does **not** claim

| Claim | Truth |
|-------|-------|
| “Impossible to track” | **No** — global passive adversary + timing analysis still correlates |
| “Carrier doesn’t know you exist” | **No** — SIM + tower registration unless you use someone else’s hotspot only |
| “Free unlimited 5G bypass” | **No** — you still use their air; you change what they learn |
| “No legal exposure” | **No** — relay operators may have duties in their jurisdiction |

Honest pitch: **commercial harvest dies; state-level targeted attack is harder and more expensive.**

---

## Smooth for humans (onboarding)

Users don’t configure onion routes.

| Setting | Meaning |
|---------|---------|
| **Ghost: Off** | Direct connection (fastest; carrier/ISP see IPs) |
| **Ghost: Home** | All traffic via home tier34 (default when away) |
| **Ghost: Circle** | Route via friends’ relays (web-of-trust) |
| **Ghost: Max** | Multipath + padding + circle relays (slower, strongest) |
| **Ghost Profile** | Decoy persona on bait lane — harvesters profile a fake human |

One toggle. Progress: “Finding a path…” not “select exit node in Romania.”

---

## Build order

1. **WireGuard to home tier34** — default Ghost: Home (v0.1)  
2. **Encrypted DNS** — default on  
3. **Friend relay** on second tier34 — Ghost: Circle (v0.5)  
4. **Multipath Wi‑Fi + cellular** — split stream (v0.5)  
5. **Padding + jitter** — anti-fingerprint (v1)  
6. **Opt-in phone relay** when charging (Hydra supply)  
7. **Ghost Profile: Light** — decoy DNS + padding on bait lane (v0.5)  
8. **Ghost Profile: Full** — scheduled synthetic persona traffic (v1)

Prior art to study: **Tor**, **Nym**, **I2P**, **WireGuard mesh**, **Mullvad multihop**, **Apple Private Relay**, **AdNauseam** / **TrackThis** (profile poisoning).

---

## Relation to other docs

- Overlay mentioned in [VISION.md](./VISION.md)  
- WireGuard/Headscale in [ONBOARDING-BUILDING-BLOCKS.md](./ONBOARDING-BUILDING-BLOCKS.md)  
- Hydra relays: [INSTALL-AND-ADOPTION.md](./INSTALL-AND-ADOPTION.md)  
- No OS telemetry: [BUILT-IN-PLATFORM.md](./BUILT-IN-PLATFORM.md)

## Open questions

1. Default Ghost mode for Tier D (bandwidth cost)?  
2. Legal safe harbour for friend relays?  
3. Abuse (spam from relay) — web-of-trust only enough?  
4. Battery policy for mobile relay?  
5. Ghost Profile persona library — regional plausibility (NG vs UK templates)?
