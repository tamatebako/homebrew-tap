# frozen_string_literal: true

# The tebako CLI formula (spec 16 §3.1): installs the four tebako
# binaries (tebako, tfs, tebako-pkg, tebako-bootstrap) per platform.
# sha256s are the release SHA256SUMS of v0.1.0 (verified at fill time).
class Tebako < Formula
  desc "tebako — package, sign, and run tebako packages (bootstrap + runtime slices + payload slices)"
  homepage "https://github.com/tamatebako/tebako"
  version "0.1.0"
  license "BSD-2-Clause"

  base = "https://github.com/tamatebako/tebako/releases/download/v#{version}"

  on_macos do
    on_arm do
      url "#{base}/tebako-#{version}-macos-arm64"
      sha256 "f4d5ad287a4a1721f111320a8c61febca143332e4788a337750a107f496acbd4"
      resource("tebako-pkg") { url "#{base}/tebako-pkg-#{version}-macos-arm64"; sha256 "2aa02dddabcf81e9cceea86b432b45ca8a044f4899717368cd4241e7c10414e0" }
      resource("tfs") { url "#{base}/tfs-#{version}-macos-arm64"; sha256 "da92bd5475f565a91e51c75048842146331828cd3439dfe62ea9e53990c4906f" }
      resource("tebako-bootstrap") { url "#{base}/tebako-bootstrap-#{version}-macos-arm64"; sha256 "af7bb8c5d6f6b02cb7e890a9f0a1dcd1775faaa6d48f3e68a5e41559634de11e" }
    end
    on_intel do
      url "#{base}/tebako-#{version}-macos-x86_64"
      sha256 "211b39a3e79a241da0836f7d3caa216512f68bbfe982bec715770078b25c2011"
      resource("tebako-pkg") { url "#{base}/tebako-pkg-#{version}-macos-x86_64"; sha256 "0e1ee2054fdc266e99a992b6ab098c0faa4dcf5b294b49f7bf7a21b2a0b7ac28" }
      resource("tfs") { url "#{base}/tfs-#{version}-macos-x86_64"; sha256 "7f379ac650af37ab5c4f69ac7ab8974c55167cfed229b31807c164dc241b03c5" }
      resource("tebako-bootstrap") { url "#{base}/tebako-bootstrap-#{version}-macos-x86_64"; sha256 "c265daeb88de660c0002abc415740d48c1a3a0a8cbb6bfad2f64f628ae96366c" }
    end
  end

  on_linux do
    on_arm do
      url "#{base}/tebako-#{version}-linux-gnu-arm64"
      sha256 "efcedda40608b9456e50289cc3626b957869058996f22aa2f2a6d11c4608ed9b"
      resource("tebako-pkg") { url "#{base}/tebako-pkg-#{version}-linux-gnu-arm64"; sha256 "0a1c16f540b56b8dd45ae7d3614a2926fbc8f4d1198ff3f9ef63a371eba2a9ed" }
      resource("tfs") { url "#{base}/tfs-#{version}-linux-gnu-arm64"; sha256 "e979744d40aecfd59ec326be25f8d4f99e23e6352d3b4ffecce43201914ffade" }
      resource("tebako-bootstrap") { url "#{base}/tebako-bootstrap-#{version}-linux-gnu-arm64"; sha256 "7e2ddf7dc5b8adb9d0313ee038a47a981cf85cd2d9eae3ebe9c9d729d6bd228b" }
    end
    on_intel do
      url "#{base}/tebako-#{version}-linux-gnu-x86_64"
      sha256 "8f442f52bdd8b0085870a71254955f33d9eb8cd4814f0909483db03546937412"
      resource("tebako-pkg") { url "#{base}/tebako-pkg-#{version}-linux-gnu-x86_64"; sha256 "da1df59cf93798b06c750fa2f82349b606c0d08d572b3a9bf925423d436b07ae" }
      resource("tfs") { url "#{base}/tfs-#{version}-linux-gnu-x86_64"; sha256 "ea83fbac5c575d5bf7fec411927a15f9db2d578565f727dd34edb4d11dac53b6" }
      resource("tebako-bootstrap") { url "#{base}/tebako-bootstrap-#{version}-linux-gnu-x86_64"; sha256 "aa5dabfc0a596ef5a5c6a5817d893dcd142e6f54dc3215bc6f7ed67d73554767" }
    end
  end

  def install
    bin.install "tebako-#{version}-#{OS.mac? ? 'macos' : 'linux-gnu'}-#{Hardware::CPU.arm? ? 'arm64' : 'x86_64'}" => "tebako"
    %w[tebako-pkg tfs tebako-bootstrap].each do |name|
      resource(name).stage do
        bin.install Dir["#{name}-#{version}-*"].first => name
      end
    end
  end

  test do
    # the banner is the tebako FORMAT version (0.15.x), not the release
    # version — assert the stable prefix, never the number
    assert_match "Tebako executable packager version", shell_output("#{bin}/tebako --version")
  end
end

# Refilling the sha256s for a future release:
#   gh release download v<X> -R tamatebako/tebako -p "SHA256SUMS" -D /tmp
#   cat /tmp/SHA256SUMS  # → 4 binaries × N platforms; slot each into the
#   matching sha256 above and bump version.
