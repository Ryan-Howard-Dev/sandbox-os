# Diátaxis map — Sandbox OS docs

This repository’s documentation is organized roughly along [Diátaxis](https://diataxis.fr/) quadrants. Mapping is imperfect (the suite grew as design notes); this file is the intentional index for readers and contributors.

## Tutorials (learning-oriented)

| Doc | Notes |
|-----|--------|
| [GETTING-STARTED.md](./GETTING-STARTED.md) | On-ramp for builders |
| [WSL-DEV-SETUP.md](./WSL-DEV-SETUP.md) | Windows + WSL bench for tier34 |

## How-to guides (task-oriented)

| Doc | Notes |
|-----|--------|
| [WSL-DEV-SETUP.md](./WSL-DEV-SETUP.md) | Start / status tier34 from Windows |
| [scripts/wsl/](../scripts/wsl/) | Operator scripts (`tier34-status`, `start-tier34-and-wait`, …) |
| [INSTALL-AND-ADOPTION.md](./INSTALL-AND-ADOPTION.md) | Spread / Hydra adoption tasks (product) |
| [FIRE-TABLET.md](./FIRE-TABLET.md) | Sideload path on Fire OS |

## Reference (information-oriented)

| Doc | Notes |
|-----|--------|
| [DECISIONS.md](./DECISIONS.md) | Immutable architecture choices (ADR-style) |
| [GLOSSARY.md](./GLOSSARY.md) | Shared terms |
| [PHASES.md](./PHASES.md) | Roadmap phases |
| [audit/documentation-manifest.md](./audit/documentation-manifest.md) | Inventory of all docs |
| [audit/*-invariants.md](./audit/) | Subsystem invariants tables |

## Explanation (understanding-oriented)

| Doc | Notes |
|-----|--------|
| [VISION.md](./VISION.md) | Why Sandbox OS |
| [BUILT-IN-PLATFORM.md](./BUILT-IN-PLATFORM.md) | Stations vs surveillance store |
| [NETWORK-OVERLAY-GHOST.md](./NETWORK-OVERLAY-GHOST.md) | Ghost / overlay concept |
| [THREAT-MODEL-TARGETED.md](./THREAT-MODEL-TARGETED.md) | Adversary model |
| [ETHICS-AND-ECONOMICS.md](./ETHICS-AND-ECONOMICS.md) | Hosted vs self-host |
| [CHRONICLE.md](./CHRONICLE.md) | Design conversation chronicle |

## Documentation practice (meta)

| Doc | Notes |
|-----|--------|
| [audit/](./audit/) | Multi-pass audit: inventory, interfaces, evidence, confidence |
| [MUSIC-CONSOLE-LINK.md](./MUSIC-CONSOLE-LINK.md) | Cross-repo map to Sandbox Music |
| [CONDUIT-LINK.md](./CONDUIT-LINK.md) | Cross-repo map to Conduit |

## Status discipline

Prefer **audit Verified Facts** over older “planned / docs only” lines when they conflict. Known drift targets are tracked as GitHub issues after publish.
