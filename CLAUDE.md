# ZoomRecovery — Claude Instructions

## What this project is

ZoomRecovery is a macOS shell script that fixes Zoom Error 1132 by clearing corrupted `*.enc.db` and `viper.ini` files from `~/Library/Application Support/zoom.us/data/`, optionally rotating the MAC address (requires root), then relaunching Zoom.

It is distributed three ways:
- **Homebrew:** `brew install twinboi90/tap/zoomrecovery`
- **PyPI:** `pip install zoomrecovery` (Python wrapper that bundles and runs the shell script)
- **GitHub releases:** direct binary download from `twinboi90/ZoomRecovery`

Current version: check `VERSION` file. Latest as of last session: `1.0.28`.

---

## Local file layout

```
/Users/drewbrowder/Documents/GitHub/ZoomRecovery/   ← main working directory
  zoomrecovery          ← the shell script (main artifact)
  VERSION               ← single line, e.g. "1.0.28"
  README.md
  LICENSE
  .gitignore
  CLAUDE.md             ← this file
  .github/
    pyproject.toml      ← Python package metadata
    src/
      zoomrecovery/
        __init__.py     ← version string (kept in sync with VERSION)
        __main__.py     ← entry point: extracts + runs _script.sh
        _script.sh      ← gitignored, generated at build time by copying zoomrecovery
    workflows/
      publish.yml       ← GitHub Actions: publishes to PyPI on release
  .claude/
    settings.json       ← Claude Code hooks (gitleaks pre-push scan)
    commands/
      check-secrets.md  ← /check-secrets slash command

/Users/drewbrowder/Documents/GitHub/tap/            ← Homebrew tap repo
  Formula/
    zoomrecovery.rb     ← updated automatically on every release

# Local-only files (gitignored, private repo only):
release.sh              ← full release automation script
build.sh                ← builds signed + notarized .pkg installer
install.sh              ← local install helper
```

---

## Git remotes (same local folder, two GitHub repos)

| Remote | GitHub repo | Visibility | Contains |
|--------|-------------|------------|---------|
| `origin` | `twinboi90/ZoomRecovery` | Public | Everything except maintenance scripts, dist/, build/, *.pkg |
| `private` | `twinboi90/ZoomRecovery-dev` | Private | Everything + `build.sh`, `install.sh`, `release.sh` |

The private sync runs automatically at the end of every `release.sh`.

**If maintenance scripts go missing** (they get deleted when switching git branches — a known issue in this environment), restore them:
```bash
git show private/main:release.sh > release.sh && chmod +x release.sh
git show private/main:build.sh > build.sh && chmod +x build.sh
git show private/main:install.sh > install.sh && chmod +x install.sh
```

---

## Release workflow

When the user says "commit and push", "ship it", "release this", or anything similar:

1. **Only bump the version if user-facing files changed** (`zoomrecovery` script, Python package source, anything users install). For config/tooling-only changes (`.claude/`, `CLAUDE.md`, `.github/` workflow tweaks, `.gitignore`), just `git add + commit + push` directly — no version bump, no `release.sh`.

2. **When a real release is needed:** auto-increment the patch version in `VERSION` (e.g. `1.0.28` → `1.0.29`). Use minor/major only if the user explicitly requests it. Never ask — just do it.

3. Run: `bash /Users/drewbrowder/Documents/GitHub/ZoomRecovery/release.sh`

**What `release.sh` does in order:**
1. Reads `VERSION`
2. Updates `.github/src/zoomrecovery/__init__.py` with the new version (using Python, not sed)
3. `git add -A && git commit -m "Release X.Y.Z" && git pull --rebase && git push` to `origin`
4. Creates and pushes the git tag → this triggers GitHub Actions → PyPI publish (Trusted Publisher, OIDC, no token needed)
5. Copies `zoomrecovery` to `/tmp/zoomrecovery`, substitutes `VERSION_PLACEHOLDER`, creates GitHub release with binary attached
6. Downloads the release binary, computes SHA256, writes new `Formula/zoomrecovery.rb` in the tap
7. Commits and pushes the tap (`twinboi90/tap`)
8. Runs `brew update && brew upgrade zoomrecovery` locally
9. Syncs private repo: `git clone . $TMP`, copies maintenance scripts, force-pushes to `private/main`, removes tmp

**PyPI:** GitHub Actions (`publish.yml`) handles this automatically when the release is published. Triggered by step 4 above. Uses PyPI Trusted Publisher — no API token, no local twine needed.

**PyPI Trusted Publisher config** (on pypi.org):
- Repo: `twinboi90/ZoomRecovery`
- Workflow: `publish.yml`
- Environment: `(Any)`

---

## Known gotchas

- **`git worktree` hangs** in this Claude Code environment — never use it. The private sync uses `git clone . $TMP` instead.
- **Maintenance scripts disappear** when switching git branches (they were once tracked in a branch, so checkout removes them). Restore from private remote as shown above.
- **`python -m build`** previously needed `PIP_USER=0` due to global pip config `user = true`. This was fixed by clearing `~/.config/pip/pip.conf`. If build issues recur, check that file.
- **`sed` with escaped quotes** is unreliable for version bumps on macOS. Always use Python: `python3 -c "import pathlib, re; f = pathlib.Path('...'); f.write_text(re.sub(...))"`.

---

## Secret scanning

Three layers are set up to prevent secrets from being pushed:

1. **Claude Code hook** — `.claude/settings.json` has a `PreToolUse` hook on `Bash(git push*)` that runs `gitleaks` before any push I attempt. Blocks with a `continue: false` response if secrets are found.
2. **Git pre-push hook** — `.git/hooks/pre-push` runs `gitleaks` before any push from anywhere (terminal, scripts, etc.).
3. **`/check-secrets` slash command** — manual scan on demand.

`gitleaks` is installed via Homebrew. Correct syntax for this version: `gitleaks git --no-banner <repo-path>` (no `--source` flag).

---

## Authentication / credentials

- **GitHub:** `gh` CLI authenticated as `twinboi90` (keyring). Token name: `github_pat_...` Scopes cover repo push, release creation.
- **PyPI:** No stored token — publishing uses GitHub Actions Trusted Publisher (OIDC). API token previously stored in keyring was removed.
- **Apple notarization** (for `.pkg` builds): Signing identity `Developer ID Installer: Drew Browder (2L6F6485AY)`, notary profile `zoomrecovery-notary`, Apple ID `Dustinthewind_89@protonmail.com`, Team ID `2L6F6485AY`.

---

## Other local repos referenced by release.sh

| Path | GitHub | Purpose |
|------|--------|---------|
| `/Users/drewbrowder/Documents/GitHub/tap` | `twinboi90/tap` | Homebrew tap — formula auto-updated on release |

---

## What was built / changed in the May 2026 session

- Set up the full automated release pipeline (did not exist before)
- Moved `build.sh`, `install.sh`, `release.sh` to private repo only
- Moved PyPI packaging (`pyproject.toml`, `src/`) inside `.github/` to keep it out of the public repo root
- Switched PyPI publishing from local `twine` + API token to GitHub Actions Trusted Publisher
- Fixed `python -m build` isolation issue (was caused by `pip.conf user=true`, now cleared)
- Fixed `sed` escaping bug in version bump (switched to Python)
- Installed `gitleaks` and set up three-layer secret scanning
- Added `.claude/settings.json` with pre-push hook
- Added `/check-secrets` slash command
