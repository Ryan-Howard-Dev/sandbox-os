# Ethics & economics — hosted membership

**Last updated:** 2026-07-07  
**Status:** Policy draft — not billing live

## Moral line

| Path | Price | What you get |
|------|-------|----------------|
| **Self-host** | **$0 forever** | Run tier34 on your PC, Pi, or VPS. Full sovereignty. No permission fee. |
| **Hosted membership** | **Regional** | We run sync, relay, backups, support — convenience, not access to existence. |
| **Spying** | **Never** | Revenue from membership, not data extraction. |

You are not selling **permission to exist** in Sandbox. You are selling **ease** for people who do not want to run a server.

## Why one global price fails

**$20/month** (or **~£16–18**) is a defensible **Tier A** anchor in the US and UK — roughly one serious subscription (Spotify Premium, Proton, VPN + small tool).

The same number worldwide is **equal** but not **fair**:

| Region | How ~$20 feels | Context |
|--------|----------------|---------|
| US, UK, Western EU, Australia | Normal premium tier | Often 1–3% of median take-home; people already pay for streaming/tools |
| Eastern EU, Brazil, Mexico | Stiff but some will pay | Spotify often ~$3–7 in those markets, not ~$13 |
| India, Indonesia, Philippines | Very expensive for mass adoption | Spotify India ~$1.50–2/mo; $20 can be a large budget share |
| Nigeria, Pakistan, Egypt, Bangladesh | Prohibitive for most | Spotify ~$1–2/mo; $20 can approach daily living costs for many |

Spotify charges ~$12 in the US and ~$1 in Nigeria for the **same product** — purchasing-power parity (PPP), not greed or charity. Sandbox’s freedom mission **requires** the same shape: expensive where incomes are high, accessible where they are not.

**Self-host stays free** so nobody is locked out of sovereignty by price.

## Regional tiers (hosted membership)

One product. **Bill in local currency** where possible (trust + clarity). Use Stripe (or similar) regional price IDs.

| Tier | Example regions | Hosted price (monthly) | vs $20 anchor |
|------|-----------------|------------------------|---------------|
| **A** | US, UK, CH, Nordics, AU | **$18–20** / **£15–17** | Baseline |
| **B** | Eastern EU, Brazil, Mexico, urban China | **$10–14** | ~30–40% off |
| **C** | India, SEA, South Africa, Turkey | **$5** | ~75% off |
| **D** | Nigeria, Pakistan, Egypt, Bangladesh, similar | **$1** | ~95% off |

You do not need to match Spotify penny for penny — you are smaller. The **shape** matters: Tier A funds build; Tier D keeps the door open.

### Optional add-ons (later)

- **Pay what you can** above Tier D floor (Signal-style support).  
- **Student / humanitarian** coupon — aligned with sovereignty narrative, not surveillance.  
- **Family / household** — one membership per home tier34 (easier to defend than per device).

## What hosted membership includes (draft)

Hosted is **not** “unlock the OS.” Self-host and local-only stations remain free.

| Included (hosted) | Self-host |
|-------------------|-----------|
| Managed tier34 (sync, relay, uptime) | You operate tier34 |
| Cross-device backup of keys/settings (opt-in) | Your backup strategy |
| Email/chat support SLA (tier-dependent) | Community / docs |
| Optional Builder tenant features (Conduit hosted mode) | Self-run Conduit on 5174 |

Exact SKU boundaries TBD when billing ships. **Music locker + local playback** must never require hosted.

## Leaks and pragmatism

| Issue | Stance |
|-------|--------|
| VPN arbitrage (US person buys Tier D) | Minor leak early on; do not over-optimize before users exist |
| Proof of residence | Avoid for v1 — honor system + payment country + occasional review |
| Conduit Clerk/Stripe today | Hosted Builder tenant product — separate from sovereign OS membership until unified |

## Relation to funding

See [FUNDING.md](./FUNDING.md) for backers and grants. **Hosted membership** is the long-term sustainability path aligned with values — not ads, not data sales.

## Open choices

1. Unified “Sandbox membership” across Music + Conduit hosted vs separate SKUs?  
2. Annual discount (2 months free)?  
3. Tier D at **$1** sustainable at scale — needs Tier A volume or grant top-up?  
4. Publish tier table publicly on website when billing goes live?
