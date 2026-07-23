# State of the Household Platform Foundation

**Document:** [TIER34-FOUNDER-BRIEF.md](./TIER34-FOUNDER-BRIEF.md) · **Authority:** [BUILT-IN-TIER34.md](./BUILT-IN-TIER34.md) (D-029)

## 1. Executive Summary

*   **What it is:** tier34 is the Household Platform Foundation of Sandbox OS. It provides local coordination, synchronization, publication, and device infrastructure through capability contracts.
*   **Why it exists:** It anchors the user's sovereign ecosystem, ensuring stations function local-first without relying on cloud vendors for trust, topology, or data ownership.
*   **Biggest architectural risk:** The Platform Foundation is presently coupled to a domain-specific Music implementation. Extraction into an independent `sandbox-server` package is the highest-priority architectural objective.

## 2. Constitutional Position

tier34 operates strictly within the five-level governance hierarchy of Sandbox OS.

```text
    Platform Constitution (BUILT-IN-PLATFORM.md)
                    │
    Platform Foundation Constitution (BUILT-IN-TIER34.md, D-029)
                    │
    Architecture Decision Records (ADRs)
                    │
    Engineering Specifications
                    │
    Reference Implementations

```

## 3. Current Implementation

The architectural concept of tier34 is a Platform Foundation. The *current implementation* is a server process.

* **Stack:** Node.js, Express.
* **Network:** Exposes the API on port `3001` (client UIs operate on `3002`).
* **Location:** Currently embedded at `sovereign-music-console/tier34-server/`.
* **Deployment:** Capable of running locally or via Docker (`SELF_HOST.md`).
* **Current state:** It heavily bundles music-specific pipelines (debrid, DLNA, Cast, OpenSubsonic) alongside core platform APIs.

## 4. Execution Matrix

This matrix maps the constitutional capabilities of tier34 against the reality of today's implementation.

| Capability | Status | Notes |
| --- | --- | --- |
| **Health Probe** | Shipped | Reachability only; no user data. |
| **Locker** | Shipped | Manifests and content-addressed blobs. |
| **Device Secrets** | Shipped | Distinct from Vault E2EE payloads. |
| **Peer Sync** | Shipped | WebSocket multi-device sessions. |
| **Outbox** | v0 Local | Basic publishing; lacks cryptographic signatures. |
| **Messages** | v0 Local | Stored as plaintext on disk today. |
| **E2E DMs** | Planned | Replaces v0 plaintext messaging. |
| **Federation Pull** | Planned (`501`) | Follows remain strictly device-local today. |

## 5. Constitutional Role

tier34 provides household infrastructure through capability contracts rather than user-facing features. Stations depend on tier34, but tier34 SHALL remain independent of any individual Station implementation. Network servers, HTTP endpoints, ports, and deployment mechanisms are implementation details rather than constitutional requirements.

## 6. Architectural Debt

| Priority | Item | Effect |
| --- | --- | --- |
| **P0** | Platform capability extraction | Decouples Platform Foundation from Music station implementation. |
| **P0** | Signature verification | Required before federation can safely exist. |
| **P1** | E2E messaging | Removes plaintext storage risk from household nodes. |
| **P1** | `sandbox-server` package | Enables independent semantic versioning and releases. |
| **P2** | Mail module | Completes household communications infrastructure. |

## 7. Platform Relationships

```text
  Stations
  ───────────────
  Music · Mail · Docs · Ghost · Pass · Shell · Tide

          │
  Capability Mesh
          │

  Platform Services
  ───────────────
  Spread · Harvest · Archive · Index

  Platform Foundations
  ───────────────
  Vault · tier34 · Identity · Canonical Storage

          │
  Platform Runtime

```

**Pass** is the user-facing credential station (launcher tile); **Vault** is the Platform Foundation for cryptographic identity & trust ([BUILT-IN-VAULT.md](./BUILT-IN-VAULT.md) v1.0.0, D-036). Spread is a Platform Service per [BUILT-IN-SPREAD.md](./BUILT-IN-SPREAD.md) v1.0.0 (D-030), not a Platform Foundation.

## 8. Current Gaps

| Area | Status |
| --- | --- |
| **Federation** | 501 (Not implemented) |
| **Outbox signatures** | Planned |
| **Mailbox encryption** | Planned |
| **Extraction** | In progress |
| **Engineering specs** | Stub |

## 9. Documentation Map

**Navigation**

* `docs/TIER34-INDEX.md` — Daily navigation hub.

**Governance**

* `BUILT-IN-PLATFORM.md` — The Platform Constitution.
* `docs/BUILT-IN-TIER34.md` — The tier34 Constitutional Specification.
* `DECISIONS.md` — Governance records (D-003, D-007, D-020, D-029, D-030).

**Architecture**

* `sandbox-os-core/docs/STATIONS-ARCHITECTURE.md` — Network and topology models.
* `sandbox-os-core/docs/TIER34-EXTRACTION.md` — The unbundling and migration plan.

**Engineering**

* `sandbox-os-core/docs/PLATFORM-API.md` — Current API routes and `OutboxEntry` models.
* `engineering/vault/sync-blob-format.md` — E2EE payload structures over tier34.

**Operations**

* `sovereign-music-console/TIER34.md` — Endpoints and quick start guide.
* `sovereign-music-console/SELF_HOST.md` — Docker deployment.
* `sandbox-os-core/server/health-check.mjs` — Client probe testing.
