# Contributing to Sandbox OS docs

Thank you for helping improve this documentation portfolio.

## What belongs here

- Architecture explanations, decisions, and platform specs  
- Audit artifacts under `docs/audit/`  
- WSL / operator how-tos under `docs/` and `scripts/wsl/`  

Runnable ISO, shell, and Spread Host **implementation** live in private `sandbox-os-core` until published. Please do not open PRs that assume that tree is in this repo.

## How to contribute

1. Open an **issue** first for factual drift (doc says X, code/audit says Y).  
2. Prefer small PRs: one topic per change.  
3. Match existing tone: direct, status-honest, no hype.  
4. For audit-related edits, preserve evidence / confidence structure where present.

## Diátaxis

See [docs/diataxis.md](./docs/diataxis.md). Prefer putting new pages in the right quadrant (tutorial / how-to / reference / explanation) instead of growing a single mega-doc.

## Local preview

These are Markdown files — use any viewer or GitHub’s preview. No build step required for this repo.
