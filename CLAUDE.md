# ZoomRecovery — Claude Instructions

## Release workflow

When the user says "commit and push", "ship it", "release this", or similar:

1. Auto-increment the patch version in `VERSION` (e.g. `1.0.28` → `1.0.29`). Use minor/major bump only if the user explicitly requests it.
2. Run `bash /Users/drewbrowder/Documents/GitHub/ZoomRecovery/release.sh`

Never ask about version numbers. Never ask for confirmation before releasing.

`release.sh` handles everything in sequence:
- Updates `.github/src/zoomrecovery/__init__.py` with the new version
- Commits and pushes to the public GitHub repo (`twinboi90/ZoomRecovery`)
- Creates and pushes the git tag
- Creates the GitHub release with the versioned binary attached
- Computes SHA256 of the release binary, updates the Homebrew formula in `twinboi90/tap`
- Commits and pushes the tap, runs `brew upgrade zoomrecovery` locally
- Syncs the private repo (`twinboi90/ZoomRecovery-dev`) via local clone

**PyPI publishing** happens automatically via GitHub Actions (`publish.yml`) triggered by the release creation. Uses Trusted Publisher (OIDC) — no API token needed, nothing local to run.

---

## Repo structure

**Local path:** `/Users/drewbrowder/Documents/GitHub/ZoomRecovery`

**Two remotes from the same local folder:**
- `origin` → `twinboi90/ZoomRecovery` (public)
- `private` → `twinboi90/ZoomRecovery-dev` (private)

**What's in the public repo:** `zoomrecovery` (shell script), `README.md`, `LICENSE`, `VERSION`, `.gitignore`, `.github/`

**What's gitignored from public:** `build.sh`, `install.sh`, `release.sh`, `dist/`, `build/`, `*.pkg`, `.github/src/zoomrecovery/_script.sh`, `.github/src/zoomrecovery.egg-info/`

**What's only in the private repo:** `build.sh`, `install.sh`, `release.sh`

**PyPI source lives inside `.github/`** (not the repo root) to keep it out of view:
- `.github/pyproject.toml`
- `.github/src/zoomrecovery/__init__.py`
- `.github/src/zoomrecovery/__main__.py`
- `.github/workflows/publish.yml`

**Homebrew tap:** `/Users/drewbrowder/Documents/GitHub/tap` — updated automatically by `release.sh`

---

## Key facts

- `release.sh` is a local-only file (gitignored). If it goes missing, restore it with: `git show private/main:release.sh > release.sh && chmod +x release.sh`
- Same for `build.sh` and `install.sh`
- PyPI Trusted Publisher is configured on pypi.org for `twinboi90/ZoomRecovery`, workflow `publish.yml`, environment `(Any)`
- The private sync in `release.sh` uses `git clone . $TMP` (not worktrees — those hang in this environment)
