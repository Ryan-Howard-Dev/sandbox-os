# Threat model — targeted investigation

**Last updated:** 2026-07-07  
**Status:** Security architecture — honest limits

## The question

> Ghost Profile fools bulk harvest. How do you stop a **targeted** investigation of **real** encrypted traffic?

**Short answer:** You cannot guarantee stopping a well-resourced adversary who can compel you, seize hardware, or correlate global traffic. You **can** make content unreadable, metadata scarce, correlation expensive, and past traffic dead even if keys are taken later.

---

## What “targeted investigation” means

| Adversary capability | Example |
|---------------------|---------|
| **Legal compulsion** | Warrant for device unlock, server seizure, account data |
| **Traffic correlation** | Watch entry relay + exit relay; match timing and volume |
| **Endpoint attack** | Malware, forensic imaging of phone, key extraction |
| **Carrier / ISP tap** | Lawful intercept on SIM or fibre |
| **Global passive collection** | Backbone taps (nation-state) |
| **Human** | Coercion, social engineering |

Different defenses for each. No single switch fixes all.

---

## Layer 1 — They cannot read content (E2E + forward secrecy)

| Control | What it stops |
|---------|---------------|
| **E2E Social station** | Message **content** unreadable on wire or seized tier34 |
| **TLS 1.3 + cert pinning** | Browser traffic content protected to site |
| **Perfect forward secrecy (PFS)** | Keys seized **today** don’t decrypt **yesterday’s** captures |
| **Double Ratchet** (Signal-class) | Compromised session key doesn’t break all history |

**Stops:** Reading what you wrote in encrypted chat.  
**Doesn’t stop:** Knowing you **talked**, **when**, **how much data**, **to which relay IP**.

---

## Layer 2 — They cannot correlate the path (mix + delay)

Ghost overlay hides IP. **Targeted** adversaries use **timing and volume** on encrypted tunnels.

| Control | What it does |
|---------|--------------|
| **Multihop relays** (Circle / Max) | No single node sees full path |
| **Mix network** (Nym-style or Sandbox mix layer) | Batch + shuffle + delay packets — breaks timing correlation |
| **Constant-rate padding** | Same bandwidth whether idle or active — hides “now they’re browsing” |
| **Split paths** | Wi‑Fi + 4G different hops — harder to merge streams |
| **Cover traffic** | Ghost Profile on bait lane **plus** dummy cells on real lane |

**Stops:** Cheap “watch both ends of tunnel” correlation.  
**Doesn’t stop:** Patient global adversary with **every** hop compromised or long-term statistical attack.

**Build order:** WireGuard multihop → padding → mixnet integration (v1+).

---

## Layer 3 — They cannot get useful logs (minimal retention)

| Control | What it does |
|---------|--------------|
| **tier34: no connection logs by default** | Seized home server has locker blobs, not “visited X at 14:03” |
| **No OS telemetry** | Nothing to subpoena from Sandbox Inc (there is no warehouse) |
| **Federation** | No single company DB of all users |
| **RAM-first modes** (optional) | Sensitive session keys never written to disk |
| **Ephemeral relay mode** | Friend’s node doesn’t persist your path |

**Stops:** “Hand us the database.”  
**Doesn’t stop:** Live tap **going forward** after they know who to watch.

---

## Layer 4 — They cannot break the device (endpoint hardening)

| Control | What it does |
|---------|--------------|
| **Keys in secure enclave** (Stronghold / TEE) | Extraction needs physical attack, not file copy |
| **Full-disk encryption** | Powered-off device resists imaging |
| **Reboot to decrypt** | Biometric + PIN for keys |
| **Duress PIN** | Second PIN wipes keys / shows decoy account |
| **Verified boot (AVB)** | Malware can’t persist in system partition easily |
| **No arbitrary sideload on system** | Signed stations only |

**Stops:** Casual forensic copy of keys from storage.  
**Doesn’t stop:** $50k lab chip-off, or you entering PIN under coercion.

---

## Layer 5 — They cannot compel what doesn’t exist (legal + design)

| Reality | Sandbox stance |
|---------|----------------|
| **UK Investigatory Powers Act / US warrant** | Courts can order unlock — **technology ≠ law immunity** |
| **Can’t decrypt E2E you don’t have keys for** | Federated social — server operator has nothing to hand over |
| **Plausible deniability** (hidden volumes) | Legally risky in UK; not default Sandbox feature |
| **Jurisdiction** | Self-host tier34 where law aligns; doesn’t help if **you** are in compulsion jurisdiction |

**Honest:** Against serious crime investigations, democratic states **will** use law. Sandbox protects **privacy as default** and **resists fishing expeditions** — not “immunity from all police.”

---

## Threat levels (what Sandbox modes target)

| Mode | Stops |
|------|-------|
| **Ghost: Home + E2E** | ISP/carrier content read; casual employer monitoring |
| **Ghost: Circle + padding** | Commercial correlators; many ISP retention queries |
| **Ghost: Max + mix** | Stronger timing resistance; researcher-grade adversary **harder** |
| **Duress PIN + enclave keys** | Opportunistic device seizure |
| **None of the above** | Nation-state with global taps + warrant + $50k forensics + you in the room |

Product promise: **raise cost until only proportionate legal investigation with endpoint access can succeed** — not “impossible for NSA.”

---

## What to build (priority)

```text
v0.1  E2E Social + WireGuard home + encrypted DNS + FDE + enclave keys
v0.5  Multihop Circle + PFS everywhere + tier34 no-log policy + duress PIN
v1    Mixnet/padding layer + cover traffic on real lane + RAM session mode
v2    Optional Nym/Tor bridge integration for Max mode
```

---

## User-facing (one screen, honest)

**Settings → Privacy → Who are you defending against?**

| Choice | Enables |
|--------|---------|
| **Everyday** | Ghost Home, E2E, no telemetry |
| **Serious** | Circle, padding, minimal logs |
| **Maximum** | Mix delay (slower), cover traffic, duress PIN |

Footnote in UI: *“No system stops a court order to unlock your phone if you comply. Sandbox makes bulk spying useless and targeted attacks expensive.”*

---

## See also

- [NETWORK-OVERLAY-GHOST.md](./NETWORK-OVERLAY-GHOST.md) — ghost routing + ghost profile  
- [BUILT-IN-PLATFORM.md](./BUILT-IN-PLATFORM.md) — no OS telemetry  
- [DECISIONS.md](./DECISIONS.md) — keys first, federation

## Open questions

1. Integrate **Nym** mixnet vs build light mix in tier34?  
2. Duress PIN legal UX in UK/EU?  
3. Mix delay defaults — how slow is acceptable for “Max”?  
4. Warrant canary / transparency report for hosted tier?
