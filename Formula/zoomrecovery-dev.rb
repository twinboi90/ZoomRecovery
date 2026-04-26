class ZoomrecoveryDev < Formula
  desc "Fix Zoom Error 1132 (Device Identification Conflict) - Development Version"
  homepage "https://github.com/twinboi90/ZoomRecovery"
  url "https://github.com/twinboi90/ZoomRecovery/archive/refs/tags/v1.2.0-dev.1.tar.gz"
  sha256 "8105e540d4680762a943055cec10609192448cb812de9ffca2d51cb754880d79"
  version "1.2.0-dev.1"
  license "MIT"

  depends_on "openssl"

  def install
    bin.install "zoomrecovery"
  end

  def post_install
    puts "\n⚠️  Development Version Installed"
    puts "This is a pre-release version for testing Zoom 7.0.0 compatibility."
    puts "\nUsage: sudo zoomrecovery"
    puts "\nTo report issues or provide feedback:"
    puts "  https://github.com/twinboi90/ZoomRecovery/issues\n\n"
  end

  test do
    system "#{bin}/zoomrecovery", "--version"
  end
end
