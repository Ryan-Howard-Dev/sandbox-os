# Publish checklist — GitHub portfolio

## A. Publish `sandbox-os` (same flow as Music)

Same as Music: **terminal only** — `origin` URL under your account, then `git push -u origin main`.

Music already had `https://github.com/Ryan-Howard-Dev/sovereign-music-console.git`.  
`sandbox-os` does not exist on GitHub yet, so one create step is required (still CLI — not a different process).

Open a **new** PowerShell (so `gh` is on PATH), or use the full path below.

```powershell
cd C:\Users\RH\Downloads\sandbox-os

$gh = "C:\Program Files\GitHub CLI\gh.exe"
& $gh auth login   # skip if already logged in

# Creates Ryan-Howard-Dev/sandbox-os and sets origin (same kind of remote Music uses)
& $gh repo create sandbox-os --public --source=. --remote=origin --description "Sandbox OS — architecture, decisions, Diátaxis map, multi-pass documentation audits"

# Same as Music from here:
git push -u origin main
```

If `gh repo create` already pushed for you, `git push` will just say up to date.

Equivalent without the combined flag — identical to re-adding Music’s origin after `filter-repo`:

```powershell
& $gh repo create sandbox-os --public --description "Sandbox OS — architecture, decisions, Diátaxis map, multi-pass documentation audits"
git remote add origin https://github.com/Ryan-Howard-Dev/sandbox-os.git
git push -u origin main
```

(`git remote add` fails if `origin` exists — then use `git remote set-url origin https://github.com/Ryan-Howard-Dev/sandbox-os.git`)

## B. Profile README

1. Create a **new public repo** named exactly `Ryan-Howard-Dev` (same as your username).  
2. Add `README.md` with the contents of [`docs/portfolio/github-profile-README.md`](./docs/portfolio/github-profile-README.md).  
3. After `sandbox-os` is live, the profile links will resolve.

```powershell
# Optional with gh:
gh repo create Ryan-Howard-Dev --public --description "Profile README"
# clone, copy docs/portfolio/github-profile-README.md → README.md, commit, push
```

## C. Pin repos (github.com → your profile → Customize pins)

1. `sovereign-music-console`  
2. `sandbox-os`  
3. `Ryan-Howard-Dev` (profile) — optional  

## D. Open starter issues on `sandbox-os` (after push)

Use template **Documentation drift**, or create manually:

1. **docs: ARCHITECTURE (os-core) still says Spread is docs-only** — Host CLI + write-usb exist; see `docs/audit/deployment-analysis.md`.  
2. **docs: MUSIC-CONSOLE-LINK claimed social/marketplace not in code** — fixed in tree; verify on GitHub after push.  
3. **docs: launcher catalog vs HTML drift (mail/vpn)** — see `docs/audit/launcher-analysis.md`.  
4. **docs: Firefox wedge vs Tide-as-product-browser** — session autostart still third-party browser.

```powershell
gh issue create --repo Ryan-Howard-Dev/sandbox-os --title "docs: track Spread status drift (docs-only vs Host CLI)" --body "ARCHITECTURE in sandbox-os-core still says Spread is docs-only. Pass 2 deployment audit shows spread-host.mjs + write-usb.sh. When os-core is public, update that table. Evidence: docs/audit/deployment-analysis.md"
gh issue create --repo Ryan-Howard-Dev/sandbox-os --title "docs: launcher catalog vs HTML grid (mail/vpn)" --body "Pass 2 launcher audit: catalog lists mail/vpn; index.html has no tiles; vpn has no loader. See docs/audit/launcher-analysis.md"
gh issue create --repo Ryan-Howard-Dev/sandbox-os --title "docs: Tide-at-boot vs Firefox/Chromium wedge" --body "Product docs describe first-party Tide; sway/labwc autostart still opens firefox-esr/chromium to :3002. See docs/audit/launcher-invariants.md"
```

## E. Do **not** publish `sandbox-os-core` yet

- Not a git repo in the Downloads checkout used for audit  
- Contains `image/live-build-work/` build debris  
- Large ISO artifacts risk  

Keep **private product chassis**; cite audits from this public docs repo. Revisit when: clean git, `.gitignore` excludes `live-build-work`/`out/*.iso`, README is operator-focused.

## F. Canonical application links (copy/paste)

1. https://github.com/Ryan-Howard-Dev/sovereign-music-console#readme  
2. https://github.com/Ryan-Howard-Dev/sovereign-music-console/blob/main/adr/001-locker-never-auto-delete.md  
3. https://github.com/Ryan-Howard-Dev/sovereign-music-console/tree/main/docs/audit  
4. https://github.com/Ryan-Howard-Dev/sandbox-os (after publish)  
5. https://github.com/Ryan-Howard-Dev/sandbox-os/blob/main/docs/DECISIONS.md  
6. https://github.com/Ryan-Howard-Dev/sandbox-os/blob/main/docs/audit/launcher-analysis.md  

## G. Optional Sphinx stub (later)

Separate tiny repo or `docs/sphinx-stub/` with `conf.py` + one reST page — only if you want to show Sphinx/reST familiarity explicitly.
