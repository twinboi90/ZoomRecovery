#!/bin/bash
set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────
PRODUCT_NAME="zoomrecovery"
VERSION_FILE="$(cd "$(dirname "$0")" && pwd)/VERSION"
if [ ! -f "$VERSION_FILE" ]; then
  echo "[!] VERSION file not found. Exiting."
  exit 1
fi
VERSION="$(cat "$VERSION_FILE" | tr -d '[:space:]')"
echo "[*] Building version: $VERSION"
IDENTIFIER="com.twinboi90.zoomrecovery"
INSTALL_LOCATION="/usr/local/bin"
SIGNING_IDENTITY="Developer ID Installer: Drew Browder (2L6F6485AY)"
NOTARY_PROFILE="zoomrecovery-notary"
APPLE_ID="Dustinthewind_89@protonmail.com"
TEAM_ID="2L6F6485AY"

# ── Paths ─────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
PKG_ROOT="$BUILD_DIR/pkg_root"
SCRIPTS_DIR="$BUILD_DIR/scripts"
OUTPUT_PKG="$SCRIPT_DIR/${PRODUCT_NAME}-${VERSION}.pkg"

# ── Clean ─────────────────────────────────────────────────────────────────────
echo "[*] Cleaning previous build..."
rm -rf "$BUILD_DIR"
mkdir -p "$PKG_ROOT$INSTALL_LOCATION"
mkdir -p "$SCRIPTS_DIR"

# ── Copy & prepare binary ─────────────────────────────────────────────────────
echo "[*] Preparing binary..."
cp "$SCRIPT_DIR/$PRODUCT_NAME" "$PKG_ROOT$INSTALL_LOCATION/$PRODUCT_NAME"
sed -i '' "s/VERSION_PLACEHOLDER/$VERSION/g" "$PKG_ROOT$INSTALL_LOCATION/$PRODUCT_NAME"
chmod 755 "$PKG_ROOT$INSTALL_LOCATION/$PRODUCT_NAME"

# ── postinstall script ────────────────────────────────────────────────────────
cat > "$SCRIPTS_DIR/postinstall" << 'EOF'
#!/bin/bash
chmod 755 /usr/local/bin/zoomrecovery
chown root:wheel /usr/local/bin/zoomrecovery
exit 0
EOF
chmod 755 "$SCRIPTS_DIR/postinstall"

# ── Build unsigned PKG ────────────────────────────────────────────────────────
echo "[*] Building package..."
pkgbuild \
  --root "$PKG_ROOT" \
  --scripts "$SCRIPTS_DIR" \
  --identifier "$IDENTIFIER" \
  --version "$VERSION" \
  --install-location "/" \
  --sign "$SIGNING_IDENTITY" \
  "$OUTPUT_PKG"

echo "[✔] Built: $OUTPUT_PKG"

# ── Notarize ──────────────────────────────────────────────────────────────────
echo "[*] Submitting for notarization..."
xcrun notarytool submit "$OUTPUT_PKG" \
  --keychain-profile "$NOTARY_PROFILE" \
  --wait

# ── Staple ───────────────────────────────────────────────────────────────────
echo "[*] Stapling notarization ticket..."
xcrun stapler staple "$OUTPUT_PKG"

echo "[✔] Done: $OUTPUT_PKG is signed, notarized, and stapled."
