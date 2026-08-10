# frozen_string_literal: true

# The tebako CLI formula (spec 16 §3.1): installs the five tebako
# binaries (tebako, tfs, tebako-pkg, tebako-shim, tebako-bootstrap) per
# platform. sha256s are the release SHA256SUMS of v0.1.2 (verified at
# fill time).
class Tebako < Formula
  desc "tebako — package, sign, and run tebako packages (bootstrap + runtime slices + payload slices)"
  homepage "https://github.com/tamatebako/tebako"
  version "0.1.2"
  license "BSD-2-Clause"

  base = "https://github.com/tamatebako/tebako/releases/download/v#{version}"

  on_macos do
    on_arm do
      url "#{base}/tebako-#{version}-macos-arm64"
      sha256 "9d8328168b93c1828059ba90baf13b4855a7de483b25ae9df9c596c1e83634a3"
      resource("tebako-pkg") { url "#{base}/tebako-pkg-#{version}-macos-arm64"; sha256 "ec5be153c2c5879b0a9a90c6e6f325ae7ac33632c81e4c97bd0ff1b91f92bb28" }
      resource("tfs") { url "#{base}/tfs-#{version}-macos-arm64"; sha256 "4b791be221501e03f2f64af155ebe6ef903f3a4a2c25733d93bfa2afb3165688" }
      resource("tebako-shim") { url "#{base}/tebako-shim-#{version}-macos-arm64"; sha256 "03bf1d5c93a50a66e31ee6443c6d88527c325828ec5910ca1a9980e8b8f6a134" }
      resource("tebako-bootstrap") { url "#{base}/tebako-bootstrap-#{version}-macos-arm64"; sha256 "3445aed6c954b67fefef6611c4d3ebd4a7b2207b3fe8d5ca62667014590e08cc" }
    end
    on_intel do
      url "#{base}/tebako-#{version}-macos-x86_64"
      sha256 "ce1410bb775e8ff9492ab178e07714ed75bd0e7c5525d95139482a67104be14c"
      resource("tebako-pkg") { url "#{base}/tebako-pkg-#{version}-macos-x86_64"; sha256 "9952398825736f5893d2587f57491088fa8b7690df0d49f9c32ac564158b6a1a" }
      resource("tfs") { url "#{base}/tfs-#{version}-macos-x86_64"; sha256 "8baafef0536b529ab10a1bcd02de28c7d37dce3dcbb2197ae401700811a88bc7" }
      resource("tebako-shim") { url "#{base}/tebako-shim-#{version}-macos-x86_64"; sha256 "f322f686ed4870572b58608a32fd9974f6294671fa8d23c13957e42c99ff2f97" }
      resource("tebako-bootstrap") { url "#{base}/tebako-bootstrap-#{version}-macos-x86_64"; sha256 "ef02b696bf89abc2aa835e7a21e53e388f6e94b46a2a9ce08fbff9f4cc37fca3" }
    end
  end

  on_linux do
    on_arm do
      url "#{base}/tebako-#{version}-linux-gnu-arm64"
      sha256 "67aa3ac7aaed346d69dfa12f70f6ad8e7ebbf17386548bfd6182b08bac7af547"
      resource("tebako-pkg") { url "#{base}/tebako-pkg-#{version}-linux-gnu-arm64"; sha256 "9722d1e899b962eaa5f78a790c9b111b65d4b1f1f092c4b3fb7cabeb6777b31d" }
      resource("tfs") { url "#{base}/tfs-#{version}-linux-gnu-arm64"; sha256 "338e8c82574a68ea568ee139fe7b3a4decccf45a02b5af1e5fe0a673b7a4d17e" }
      resource("tebako-shim") { url "#{base}/tebako-shim-#{version}-linux-gnu-arm64"; sha256 "4505047201ae519bf063d4b8b770e007e50d760fa8fda90d82c99c6c564e3c44" }
      resource("tebako-bootstrap") { url "#{base}/tebako-bootstrap-#{version}-linux-gnu-arm64"; sha256 "1ab11d209e2b77d6828558a1772252d7287e1d325f7cd0a1e5a1fca8f4beecc7" }
    end
    on_intel do
      url "#{base}/tebako-#{version}-linux-gnu-x86_64"
      sha256 "8b45d11199a5b878abcae3746f8c0ecb6a53e871890bdbd5d9d1e537a8d1f59e"
      resource("tebako-pkg") { url "#{base}/tebako-pkg-#{version}-linux-gnu-x86_64"; sha256 "10a6f194d9ffd992f8a20da6933a407b78540ca1769048d43881ef963959a5e8" }
      resource("tfs") { url "#{base}/tfs-#{version}-linux-gnu-x86_64"; sha256 "07e47cf05fe19cbc726ad028e2ec8463502809c819c71d78449bc7a5650b95b4" }
      resource("tebako-shim") { url "#{base}/tebako-shim-#{version}-linux-gnu-x86_64"; sha256 "8cdc6194495dab1b1e575f7313821b2837e4d793f9b710427329649827bef9e8" }
      resource("tebako-bootstrap") { url "#{base}/tebako-bootstrap-#{version}-linux-gnu-x86_64"; sha256 "1dab82e238458ef33aeb5f467e7f80cbf202aaa710c738995279144b5f87cdb3" }
    end
  end

  def install
    bin.install "tebako-#{version}-#{OS.mac? ? 'macos' : 'linux-gnu'}-#{Hardware::CPU.arm? ? 'arm64' : 'x86_64'}" => "tebako"
    %w[tebako-pkg tfs tebako-shim tebako-bootstrap].each do |name|
      resource(name).stage do
        bin.install Dir["#{name}-#{version}-*"].first => name
      end
    end
  end

  def caveats
    <<~EOS
      Put the payload shims on your PATH (one per installed payload command):
        tebako-shim install-shell            # inserts the managed block into your shell rc
      musl hosts (alpine and friends): use install.sh — it selects the
      linux-musl binaries; this formula is the gnu line.
    EOS
  end

  test do
    # The banner flows from the crate semver since v0.1.3 (v0.1.2 prints
    # the frozen 0.15.9) — assert the stable prefix, never the number.
    assert_match "Tebako executable packager version", shell_output("#{bin}/tebako --version")

    # The dogfood hello (prepublish/07's acceptance): registry add ->
    # payload install -> runtime download-on-demand -> shim -> run.
    # TEBAKO_HOME is test-local; nothing touches the user's store.
    ENV["TEBAKO_HOME"] = (testpath/".tebako").to_s
    system bin/"tebako", "add-registry", "tfs:github:tebako-packages/hello"
    system bin/"tebako", "install", "hello"
    assert_match "Hello, world!", shell_output("#{testpath}/.tebako/shims/hello")
  end
end

# Refilling the sha256s for a future release:
#   gh release download v<X> -R tamatebako/tebako -p "SHA256SUMS" -D /tmp
#   cat /tmp/SHA256SUMS  # → 5 binaries × N platforms; slot each into the
#   matching sha256 above and bump version.
