# ZoomRecovery Development Version - Testing Guide

## Installing the Development Version

The `zoomrecovery-dev` formula provides early access to new features and improvements before they're released as stable.

### Installation

```bash
# If you haven't already tapped the formula
brew tap twinboi90/tap

# Install the development version
brew install zoomrecovery-dev
```

### Upgrading

```bash
brew upgrade zoomrecovery-dev
```

### Uninstalling

```bash
brew uninstall zoomrecovery-dev
```

---

## What to Test

### Version Information
The current development version (`1.2.0-dev`) includes:

- ✅ **Zoom 7.0.0 Compatibility** — Enhanced cache clearing for new WebKit authentication locations
- ✅ **Security Hardening** — Fixed unsafe `eval` vulnerability in home directory expansion
- ✅ **Improved Error Handling** — Better feedback when osascript or file operations fail
- ✅ **MAC Spoofing Validation** — Checks that `spoof-mac` binary is executable before use
- ✅ **Wi-Fi Stability** — Improved race condition handling during MAC address changes

### Test Scenarios

1. **Zoom 6.7.7 Users** (Backward Compatibility)
   - [ ] Run `sudo zoomrecovery` with Zoom 6.7.7
   - [ ] Verify Zoom closes and reopens successfully
   - [ ] Verify cache files are cleared (check `~/Library/Application\ Support/zoom.us/data/`)
   - [ ] Verify MAC address was spoofed on active interfaces

2. **Zoom 7.0.0 Users** (Forward Compatibility)
   - [ ] Run `sudo zoomrecovery` with Zoom 7.0.0
   - [ ] Verify Zoom closes and reopens successfully
   - [ ] Verify new cache locations are cleared:
     - `~/Library/Application\ Support/zoom.us/data/UnifyWebView_Cache/`
     - `~/Library/HTTPStorages/us.zoom.xos*`
     - `~/Library/WebKit/us.zoom.xos/`
     - `~/Library/Caches/us.zoom.xos/`
   - [ ] Verify MAC address was spoofed
   - [ ] Verify Error 1132 is resolved (reconnect to Zoom without authentication issues)

3. **MAC Spoofing** (All Users)
   - [ ] Test with Wi-Fi interface
     - [ ] Verify Wi-Fi power cycles correctly
     - [ ] Verify MAC address changes
     - [ ] Verify Wi-Fi reconnects with new MAC
   - [ ] Test with Ethernet interface (if available)
     - [ ] Verify MAC address changes
     - [ ] Verify DHCP renewal succeeds
   - [ ] Test with `spoof-mac` installed
     - [ ] Verify spoof-mac is used (check output for "via spoof-mac")
   - [ ] Test without `spoof-mac`
     - [ ] Verify fallback to manual method works (check output for "manual spoof")

4. **Error Handling**
   - [ ] Run with Zoom already closed
     - [ ] Should skip Zoom quit gracefully
   - [ ] Run with no active physical interfaces
     - [ ] Should skip MAC spoofing with appropriate message
   - [ ] Run without sudo privileges
     - [ ] Should fail gracefully and offer to re-run with sudo

---

## Reporting Issues

Found a problem? Please report it on GitHub:

**Issue Title:** Include the version, Zoom version, and macOS version
- Example: `[zoomrecovery-dev] MAC spoofing fails on Zoom 7.0.0 with spoof-mac`

**Issue Body:** Include:
1. Your Zoom version: `defaults read /Applications/Zoom.us.app/Contents/Info CFBundleShortVersionString`
2. Your macOS version: `sw_vers`
3. Whether `spoof-mac` is installed: `which spoof-mac`
4. Full output of running `sudo zoomrecovery`
5. Which test scenario(s) failed

**Link:** https://github.com/twinboi90/ZoomRecovery/issues

---

## Version History

### 1.2.0-dev (Current)
- Fix unsafe `eval` vulnerability (critical security)
- Add Zoom 7.0.0+ WebKit cache clearing
- Improve error handling throughout
- Validate spoof-mac binary before use
- Better Wi-Fi re-enable logic
- Enhanced user feedback and logging

### 1.1.0 (Stable)
- Initial release with MAC spoofing and cache clearing
- Support for Zoom 6.7.7

---

## Frequently Asked Questions

### Q: Is it safe to test the dev version?
**A:** Yes! The dev version is thoroughly analyzed for security issues and includes a critical security fix over v1.1.0. However, it's recommended to test on a non-critical system first.

### Q: Can I switch back to the stable version?
**A:** Yes, easily:
```bash
brew uninstall zoomrecovery-dev
brew install zoomrecovery
```

### Q: What if I find a bug?
**A:** Please report it on GitHub with the information above. Your feedback is critical for making v1.2.0 stable!

### Q: When will v1.2.0 be released as stable?
**A:** After sufficient testing feedback and verification on both Zoom 6.7.7 and 7.0.0.

### Q: Can I run both zoomrecovery and zoomrecovery-dev?
**A:** No - they conflict. You should uninstall one before installing the other. The dev version is a complete replacement for testing purposes.

---

## Thank You for Testing!

Your testing feedback is invaluable in ensuring ZoomRecovery works reliably across Zoom versions.
