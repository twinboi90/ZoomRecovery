#!/bin/bash
set -e

# ── Read version from VERSION file ────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION_FILE="$SCRIPT_DIR/VERSION"
if [ ! -f "$VERSION_FILE" ]; then
  echo "[!] VERSION file not found. Exiting."
  exit 1
fi
VERSION="$(cat "$VERSION_FILE" | tr -d '[:space:]')"
echo "[*] Releasing version: $VERSION"

# ── Navigate to main ZoomRecovery repo ───────────────────────────────────────
cd /Users/drewbrowder/Documents/GitHub/ZoomRecovery

# Commit and push any pending changes
git add -A
git commit -m "Release $VERSION" || echo "[*] Nothing new to commit"
git pull --rebase
git push

# Create and push release tag
git tag "$VERSION"
git push origin "$VERSION"

# ── Create GitHub Release with binary attached ────────────────────────────────
echo "[*] Creating GitHub release and attaching binary..."
gh release create "$VERSION" zoomrecovery \
  --title "$VERSION" \
  --notes "Release $VERSION"

# ── Wait for GitHub to publish the release asset ─────────────────────────────
echo "[*] Waiting for GitHub to publish release asset..."
sleep 5

# ── Download the release binary and calculate SHA256 ─────────────────────────
echo "[*] Fetching binary and computing SHA256..."
SHA256=$(curl -sL "https://github.com/twinboi90/ZoomRecovery/releases/download/$VERSION/zoomrecovery" | shasum -a 256 | awk '{print $1}')
echo "[*] SHA256: $SHA256"

# ── Navigate to homebrew tap ──────────────────────────────────────────────────
cd /Users/drewbrowder/Documents/GitHub/homebrew-tap

# Update the formula
cat > Formula/zoomrecovery.rb <<EOF
class Zoomrecovery < Formula
  desc "Fix Zoom error 1132 by clearing corrupted database files"
  homepage "https://github.com/twinboi90/ZoomRecovery"
  url "https://github.com/twinboi90/ZoomRecovery/releases/download/$VERSION/zoomrecovery"
  sha256 "$SHA256"
  license "MIT"

  depends_on :macos

  def install
    bin.install "zoomrecovery"
  end

  test do
    assert_match "zoomrecovery", shell_output("#{bin}/zoomrecovery --version")
  end
end
EOF

# Commit and push formula update
git add Formula/zoomrecovery.rb
git commit -m "Update zoomrecovery to $VERSION"
git pull --rebase
git push

# ── Update Homebrew locally ───────────────────────────────────────────────────
echo "[*] Updating Homebrew..."
brew update
brew upgrade zoomrecovery

echo "[✔] Release $VERSION complete."
