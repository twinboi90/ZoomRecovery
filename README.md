# ZoomRecovery

A macOS utility that fixes Zoom error 1132 by clearing corrupted Zoom database files and optionally rotating network MAC addresses to clear device identity cache.

## What It Does

Zoom error 1132 occurs when the Zoom client stores corrupted authentication or state data in encrypted database files. The error persists across reinstalls because Zoom's data directory remains unchanged. ZoomRecovery resolves this by:

1. **Wiping Zoom Data**: Clears `*.enc.db` and `viper.ini` files in `~/Library/Application Support/zoom.us/data/`
2. **MAC Spoofing** (optional, root required): Rotates MAC addresses on active physical network interfaces to break device identification
3. **Reopening Zoom**: Launches the Zoom app so it rebuilds clean state files

This approach is more effective than uninstalling Zoom, as it targets the root cause—corrupted persistent data—without disrupting the application itself.

## Installation

### Homebrew

```bash
brew tap twinboi90/zoomrecovery
brew install zoomrecovery
```

### Manual

Download the latest `.pkg` installer from [GitHub Releases](https://github.com/twinboi90/ZoomRecovery/releases) and double-click to install.

Or clone and run directly:

```bash
git clone https://github.com/twinboi90/ZoomRecovery.git
cd ZoomRecovery
./zoomrecovery
```

## Usage

### Basic (Zoom Data Cleanup Only)

```bash
zoomrecovery
```

Clears Zoom's corrupted database files and reopens the app. Works without sudo, but prompts for your password to access data files.

### Full Recovery (with MAC Spoofing)

Run with root privileges to additionally spoof MAC addresses on all active physical network interfaces:

```bash
sudo zoomrecovery
```

This is useful if error 1132 persists even after data cleanup, as the device may be blocked at the network level.

### Version

```bash
zoomrecovery --version
zoomrecovery -v
```

## How It Works

### Zoom Data Wipe

The script targets two files in Zoom's persistent storage:

- **`*.enc.db`**: Encrypted SQLite databases containing Zoom's state, contacts, and authentication tokens
- **`viper.ini`**: Zoom's configuration file

The script safely wipes these files by:

1. Detecting and temporarily removing immutable flags (`uchg`) set by Zoom
2. Ensuring write permissions are available
3. Zeroing the file contents
4. Restoring original file permissions and flags

This forces Zoom to regenerate these files with fresh state on next launch.

### MAC Spoofing (Root Mode)

When running with `sudo`, the script identifies all active physical network interfaces and applies random MAC addresses. This clears any device-level blocks Zoom's backend servers may have cached.

The process:

1. Detects active physical interfaces (excludes loopback, virtual, and tunnel adapters)
2. Powers down Wi-Fi if present (to enable MAC change)
3. Applies a randomly generated locally-administered MAC address
4. Re-enables the interface and renews DHCP
5. Repeats for all physical interfaces

**Note**: Some Ethernet adapters may not support MAC spoofing; the script handles this gracefully by skipping unsupported interfaces.

### Process Cleanup

The script forcibly terminates all Zoom processes (including helper processes) before data cleanup to prevent file locks or conflicts:

```bash
pkill -9 -f zoom
```

## Requirements

- **OS**: macOS 10.12 (Sierra) or later
- **Dependencies**: None (uses built-in macOS utilities: `networksetup`, `ifconfig`, `chflags`, `chmod`)
- **Zoom**: Must be installed (script uses `open -a "zoom.us"` to relaunch)

For root-required features (MAC spoofing), your user must have sudo privileges.

## Troubleshooting

### Script fails with "sudo failed" message

The script attempts to escalate to root to perform MAC spoofing. If sudo fails, it falls back to cleanup-only mode, which works without root. If you see this warning:

```
[!] sudo failed; continuing with partial functionality (Zoom data cleanup)…
```

The data cleanup will still occur. If you need MAC spoofing, check your sudo privileges:

```bash
sudo -v
```

### Wi-Fi or Ethernet loses connectivity after running

MAC address changes require DHCP renewal. If connectivity doesn't return within 30 seconds, manually renew:

```bash
# For Wi-Fi (replace en0 if different)
networksetup -setairportpower Wi-Fi off
sleep 2
networksetup -setairportpower Wi-Fi on

# For Ethernet (adjust interface name as needed)
ipconfig set en0 DHCP
```

Check your active interfaces with:

```bash
ifconfig | grep "^[a-z]" | awk '{print $1}'
```

### Zoom crashes immediately after opening

This indicates a different issue (likely missing dependencies or installer corruption). Try reinstalling Zoom:

```bash
# Remove Zoom
rm -rf /Applications/zoom.us.app
rm -rf ~/Library/Application\ Support/zoom.us

# Reinstall from https://zoom.us/download
```

Then run ZoomRecovery again.

### "Could not detect a Wi-Fi interface" error

The script detected your system's Wi-Fi hardware port but couldn't identify its interface name. This is typically safe to ignore—the script will skip Wi-Fi MAC spoofing and process other interfaces. If you need Wi-Fi spoofing:

```bash
networksetup -listallhardwareports
```

And file an issue with the output on GitHub.

### Implementation Notes

- **Hard Kill**: Uses `pkill -9 -f zoom` rather than graceful quit. This prevents Zoom helper processes from rewriting database files during shutdown, which would re-corrupt them.
- **Glob Safety**: Enables `nullglob` before expanding `*.enc.db` to avoid errors if no files match.
- **Permission Preservation**: Captures original file permissions with `stat` and restores them after wiping, preserving Zoom's permission model.
- **MAC Generation**: Creates locally-administered MACs using `openssl rand` to ensure uniqueness without vendor conflicts.

## Contributing

Bug reports and pull requests are welcome. Please include:

- macOS version (`sw_vers`)
- Output from running with `-x` flag (debug mode): `bash -x zoomrecovery`
- Description of the error and whether standard troubleshooting (reinstall, cache clear) was attempted

## License

MIT License. See LICENSE for details.

**Feedback or issues?** Open an issue on [GitHub](https://github.com/twinboi90/ZoomRecovery/issues).