# Glossary

## Don’t boil the ocean

**Meaning:** Don’t try to solve *everything at once* in one release.

The phrase comes from the absurd image of boiling the entire ocean to cook one fish — you’d exhaust yourself before anything works.

**In Sandbox OS terms:**

| Boiling the ocean (avoid early) | Shallow end of the pool (do first) |
|--------------------------------|-------------------------------------|
| Replace Windows + iOS + Android for everyone | Linux shell + one mobile path that *you* use daily |
| Global fan counts + bank + national voting | Music + follows + messages on *your* server |
| Marketplace in every country with payments day one | Locker listings on LAN / between trusted friends |
| Custom kernel from scratch | Linux kernel + your userspace and protocols |

You keep the **20-year vision**. You ship **one loop** that proves the model, then widen.

## Station

A built-in or Builder-installed module in Sandbox OS (e.g. Music, Social, Marketplace). Stations share identity, event bus, and Sandbox Server sync — they are not siloed App Store apps.

## Sandbox Server (tier34)

Self-hosted node (default port 3001). Extraction, locker blobs, device secret sync, taste share, Connect relay. In the OS story, each person or household runs one; federation connects servers peer-to-peer.

## Locker

Local vault for files (music today; goods/photos for marketplace tomorrow). Already conceptually “in place” on devices worldwide — the OS reuses storage + sync instead of inventing new cloud warehouses.

## Federation

Servers (or clients) pull **only what you publish** (follows, public listings, signed taste) from **other people’s servers** — no central spy database.

## Freedom over priority

Reuse planet-scale infrastructure (TCP/IP, phones, storage, payment rails where needed) but change **who controls data and profit**: user-owned nodes, opt-in sharing, no default surveillance.
