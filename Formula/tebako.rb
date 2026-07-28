# frozen_string_literal: true

# The tebako CLI formula (spec 16 §3.1): installs the four tebako
# binaries (tebako, tfs, tebako-pkg, tebako-bootstrap) per platform.
# sha256 placeholders are filled from the release SHA256SUMS at tag time.
class Tebako < Formula
  desc "tebako — package, sign, and run tebako packages (bootstrap + runtime slices + payload slices)"
  homepage "https://github.com/tamatebako/tebako"
  version "0.1.0"
  license "BSD-2-Clause"

  base = "https://github.com/tamatebako/tebako/releases/download/v#{version}"

  on_macos do
    on_arm do
      url "#{base}/tebako-v#{version}-macos-arm64"
      sha256 "@@SHA256_TEBAKO_MACOS_ARM64@@"
      resource("tebako-pkg") { url "#{base}/tebako-pkg-v#{version}-macos-arm64"; sha256 "@@SHA256_PKG_MACOS_ARM64@@" }
      resource("tfs") { url "#{base}/tfs-v#{version}-macos-arm64"; sha256 "@@SHA256_TFS_MACOS_ARM64@@" }
      resource("tebako-bootstrap") { url "#{base}/tebako-bootstrap-v#{version}-macos-arm64"; sha256 "@@SHA256_BOOT_MACOS_ARM64@@" }
    end
    on_intel do
      url "#{base}/tebako-v#{version}-macos-x86_64"
      sha256 "@@SHA256_TEBAKO_MACOS_X86_64@@"
      resource("tebako-pkg") { url "#{base}/tebako-pkg-v#{version}-macos-x86_64"; sha256 "@@SHA256_PKG_MACOS_X86_64@@" }
      resource("tfs") { url "#{base}/tfs-v#{version}-macos-x86_64"; sha256 "@@SHA256_TFS_MACOS_X86_64@@" }
      resource("tebako-bootstrap") { url "#{base}/tebako-bootstrap-v#{version}-macos-x86_64"; sha256 "@@SHA256_BOOT_MACOS_X86_64@@" }
    end
  end

  on_linux do
    on_arm do
      url "#{base}/tebako-v#{version}-linux-gnu-arm64"
      sha256 "@@SHA256_TEBAKO_LINUX_GNU_ARM64@@"
      resource("tebako-pkg") { url "#{base}/tebako-pkg-v#{version}-linux-gnu-arm64"; sha256 "@@SHA256_PKG_LINUX_GNU_ARM64@@" }
      resource("tfs") { url "#{base}/tfs-v#{version}-linux-gnu-arm64"; sha256 "@@SHA256_TFS_LINUX_GNU_ARM64@@" }
      resource("tebako-bootstrap") { url "#{base}/tebako-bootstrap-v#{version}-linux-gnu-arm64"; sha256 "@@SHA256_BOOT_LINUX_GNU_ARM64@@" }
    end
    on_intel do
      url "#{base}/tebako-v#{version}-linux-gnu-x86_64"
      sha256 "@@SHA256_TEBAKO_LINUX_GNU_X86_64@@"
      resource("tebako-pkg") { url "#{base}/tebako-pkg-v#{version}-linux-gnu-x86_64"; sha256 "@@SHA256_PKG_LINUX_GNU_X86_64@@" }
      resource("tfs") { url "#{base}/tfs-v#{version}-linux-gnu-x86_64"; sha256 "@@SHA256_TFS_LINUX_GNU_X86_64@@" }
      resource("tebako-bootstrap") { url "#{base}/tebako-bootstrap-v#{version}-linux-gnu-x86_64"; sha256 "@@SHA256_BOOT_LINUX_GNU_X86_64@@" }
    end
  end

  def install
    bin.install "tebako-v#{version}-#{OS.mac? ? 'macos' : 'linux-gnu'}-#{Hardware::CPU.arm? ? 'arm64' : 'x86_64'}" => "tebako"
    %w[tebako-pkg tfs tebako-bootstrap].each do |name|
      resource(name).stage do
        bin.install Dir["#{name}-v#{version}-*"].first => name
      end
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tebako --version")
  end
end

# Filling the sha256s (run when the release exists):
#   gh release download v0.1.0 -R tamatebako/tebako -p "SHA256SUMS" -D /tmp
#   cat /tmp/SHA256SUMS  # → 4 binaries × 4 platforms; slot each into the
#   @@SHA256_<BIN>_<PLATFORM>@@ placeholders above and commit.
