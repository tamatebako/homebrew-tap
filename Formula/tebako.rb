# frozen_string_literal: true

# The tebako CLI formula (spec 16 §3.1): installs the five tebako
# binaries (tebako, tfs, tebako-pkg, tebako-shim, tebako-bootstrap) per
# platform. sha256s are the release SHA256SUMS of v2.8.17 (verified at
# fill time).
class Tebako < Formula
  desc "tebako — package, sign, and run tebako packages (bootstrap + runtime slices + payload slices)"
  homepage "https://github.com/tamatebako/tebako"
  version "2.8.17"
  license "BSD-2-Clause"

  base = "https://github.com/tamatebako/tebako/releases/download/v#{version}"

  on_macos do
    on_arm do
      url "#{base}/tebako-#{version}-macos-arm64"
      sha256 "a94a9ec6b12fcff1d3c8889befebcc8f6d306bfc81a47696cd4268c97682cccd"
      resource("tebako-pkg") { url "#{base}/tebako-pkg-#{version}-macos-arm64"; sha256 "06dd19d7ecb14f54b4ed68b15a981b06cf596ed5131d2a1f86d3cbcd5bbed9b6" }
      resource("tfs") { url "#{base}/tfs-#{version}-macos-arm64"; sha256 "f2c957bd27a3b2fea871e04bdf5c8de3689a8327a1474ca698e3936eaf239661" }
      resource("tebako-shim") { url "#{base}/tebako-shim-#{version}-macos-arm64"; sha256 "cb7b888bb31916b58b79dec99e6b7baf97d1280bea9bb31768ec8ddef3769071" }
      resource("tebako-bootstrap") { url "#{base}/tebako-bootstrap-#{version}-macos-arm64"; sha256 "931088bf0b4046e73ae5da346ec5b2c88271a9ef0f35d57dd9ee9c668a929396" }
    end
    on_intel do
      url "#{base}/tebako-#{version}-macos-x86_64"
      sha256 "16beb4f8624af7a06f1c9b33ece68ecb8bb372974a47d679055361aa9134a2dd"
      resource("tebako-pkg") { url "#{base}/tebako-pkg-#{version}-macos-x86_64"; sha256 "34e7a21cf2b1d4041a82fe6470796794bc3bb4e2edf9b9d5d1e56e9dd22da8f6" }
      resource("tfs") { url "#{base}/tfs-#{version}-macos-x86_64"; sha256 "cda457657c1eec648091b23df0c2b3119b1af9cfc1dbd95297772ee546f7ec53" }
      resource("tebako-shim") { url "#{base}/tebako-shim-#{version}-macos-x86_64"; sha256 "d57e3300cfe4ecfab376d9dd093b969be164dfedd07b0aa0e32ab48985da4261" }
      resource("tebako-bootstrap") { url "#{base}/tebako-bootstrap-#{version}-macos-x86_64"; sha256 "6e68a627698c575410678ac0f03b8266dfba6cbdd7fb95c402c32cfdbc7c9319" }
    end
  end

  on_linux do
    on_arm do
      url "#{base}/tebako-#{version}-linux-gnu-arm64"
      sha256 "49fcc1af528d949a07df650d32122b172a3f2584b4a78e812fe62fad2025ea2a"
      resource("tebako-pkg") { url "#{base}/tebako-pkg-#{version}-linux-gnu-arm64"; sha256 "e12e5f6159173feba0442187614ef9c88b348032affbe22ba4ca71b65456c214" }
      resource("tfs") { url "#{base}/tfs-#{version}-linux-gnu-arm64"; sha256 "7ced6afe31e540d63057b5eb3d62de2a1e2879a4ebec859c50d78c4356f95c86" }
      resource("tebako-shim") { url "#{base}/tebako-shim-#{version}-linux-gnu-arm64"; sha256 "290ab547d53d31863c82b5ffc97e3e5792e40a87dd18177f2effa8338cf62a01" }
      resource("tebako-bootstrap") { url "#{base}/tebako-bootstrap-#{version}-linux-gnu-arm64"; sha256 "51dfc5827d541f926d1edfa5f9cfd3ca03149f7eb1d01a2b3b1ba4e991e7600f" }
    end
    on_intel do
      url "#{base}/tebako-#{version}-linux-gnu-x86_64"
      sha256 "355c81b97d86c4a76f215e46b9570cf4f30df44d5bb086c13459ff7e0de12929"
      resource("tebako-pkg") { url "#{base}/tebako-pkg-#{version}-linux-gnu-x86_64"; sha256 "ae8a21f2f98df7ed9a8cf5ade87ff49005455de4b5f820cb39baf404ee6799e6" }
      resource("tfs") { url "#{base}/tfs-#{version}-linux-gnu-x86_64"; sha256 "083e4886f751901493d124cf90f8dc20a88fb9ba0877db9af1a5b42d0c1d64db" }
      resource("tebako-shim") { url "#{base}/tebako-shim-#{version}-linux-gnu-x86_64"; sha256 "9a3599f815f6246929ea69e5c39379b5ba5161997756b57b923e524c706fbc03" }
      resource("tebako-bootstrap") { url "#{base}/tebako-bootstrap-#{version}-linux-gnu-x86_64"; sha256 "13c1db648f592c80115fb2a4508778fd3aca6617546a017a7008c3916f62f5cf" }
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

  def post_install
    # spec 37 §6: seed the official registry into the user's config
    # (authored, user-removable; idempotent). Soft — a network hiccup
    # never fails the install; `tebako setup` re-runs anytime.
    system(bin/"tebako", "setup") or opoo "tebako setup did not complete — re-run `tebako setup` when online"
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
