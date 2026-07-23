# Sandbox OS

**Public documentation portfolio** for a sovereign operating environment: stations (Music, Browser, Builder, Social, Marketplace, …), household **Sandbox Server (tier34)**, and **Spread** install — not an app store of wrappers.

This repository is **architecture, decisions, and documentation practice**. Runnable shell / ISO / Spread Host live in a separate private platform tree (`sandbox-os-core`) until that tree is cleaned for release.

| Project | Public? | Role |
|---------|---------|------|
| **[Sandbox Music](https://github.com/Ryan-Howard-Dev/sovereign-music-console)** | Yes | Shipped station + tier34 server + ADRs + multi-pass audit |
| **Sandbox OS** (this repo) | Yes | Vision, decisions, platform specs, audit Pass 1–2 |
| **Sandbox Conduit** (Builder) | Private product | Creative stations / Tide browser (documented via link notes) |
| **sandbox-os-core** | Private for now | Bootable shell, ISO, Spread Host (audited; not published yet) |

## Start here (Diátaxis)

| Need | Go to |
|------|--------|
| **Explanation** — why Sandbox OS | [docs/VISION.md](./docs/VISION.md) · [docs/diataxis.md](./docs/diataxis.md) |
| **Reference** — immutable decisions | [docs/DECISIONS.md](./docs/DECISIONS.md) |
| **How-to** — WSL / tier34 bench | [docs/WSL-DEV-SETUP.md](./docs/WSL-DEV-SETUP.md) · [scripts/wsl/](./scripts/wsl/) |
| **Practice** — multi-pass audit artifacts | [docs/audit/](./docs/audit/) |

More index detail: [docs/diataxis.md](./docs/diataxis.md).

## Documentation practice (audit)

Pass 1 inventory and Pass 2 subsystem audits (launcher, Spread Host, Conduit provider routing) live under [`docs/audit/`](./docs/audit/). Each Pass 2 analysis separates **Verified Facts**, **Architectural Interpretation**, and **Engineering Assessment**, with machine-readable evidence blocks and confidence ratings (High / Medium / Low / Unknown).

| Artifact | Purpose |
|----------|---------|
| [documentation-manifest.md](./docs/audit/documentation-manifest.md) | Master TOC of docs |
| [BUILT-IN-DOCS.md](./docs/BUILT-IN-DOCS.md) | Docs/Sheets station spec (planning only) |
| [launcher-analysis.md](./docs/audit/launcher-analysis.md) | Node Station Launcher & Daemon |
| [deployment-analysis.md](./docs/audit/deployment-analysis.md) | Spread Host USB deployment |
| [provider-analysis.md](./docs/audit/provider-analysis.md) | Conduit provider / model routing |

## Principles

- **Local-first** — data on device and *your* Sandbox Server  
- **Stations, not apps** — modules of one OS, not rented silos  
- **Keys, not accounts** — cryptographic identity; federation optional  
- **Honest status** — specs say when code is missing; audits call out doc drift  

## Status

- **This repo:** public documentation + WSL helper scripts  
- **Living products:** Sandbox Music (public), Conduit (private)  
- **Bootable OS chassis:** private until ISO/worktree cleanup — see audit notes on Spread vs “docs only” drift in older architecture text  

## Contributing

Doc fixes and issue reports welcome — see [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

Documentation and scripts in this repository are licensed under [MIT](./LICENSE).
