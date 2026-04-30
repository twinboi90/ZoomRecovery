class ZoomrecoveryDev < Formula
  desc "Fix Zoom Error 1132 (Device Identification Conflict) - Development Version"
  homepage "https://github.com/twinboi90/ZoomRecovery"
  url "https://github.com/twinboi90/ZoomRecovery/archive/refs/tags/v1.3.0-dev.1.tar.gz"
  sha256 "PLACEHOLDER"
  version "1.3.0-dev.1"
  license "MIT"

  depends_on "openssl"

  def install
    bin.install "zoomrecovery-dev"
  end

  def post_install
    puts "\n⚠️  Development Version Installed"
    puts "This is a pre-release version with sandbox-based identity masking"
    puts "for Zoom 7.0.0+ on macOS (Intel and Apple Silicon)."
    puts ""
    puts "Usage: sudo zoomrecovery-dev"
    puts ""
    puts "What's new in v1.3.0-dev:"
    puts "  - Sandbox-exec blocks Zoom from reading hardware IDs"
    puts "  - Private Wi-Fi Address cycling for Apple Silicon + macOS 14+"
    puts "  - Full cleanup of caches, preferences, and saved state"
    puts "  - DNS cache flush"
    puts "  - Selective data wipe (enc.db + viper.ini only)"
    puts ""
    puts "To report issues or provide feedback:"
    puts "  https://github.com/twinboi90/ZoomRecovery/issues\n\n"
  end

  test do
    system "#{bin}/zoomrecovery-dev", "--version"
  end
end
