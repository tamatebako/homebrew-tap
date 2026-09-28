# frozen_string_literal: true

# The tebako CLI formula (spec 16 §3.1): installs the five tebako
# binaries (tebako, tfs, tebako-pkg, tebako-shim, tebako-bootstrap) per
# platform. sha256s are the release SHA256SUMS of v2.8.19 (verified at
# fill time).
class Tebako < Formula
  desc "Package, sign, and run stitched tebako packages and payload slices"
  homepage "https://github.com/tamatebako/tebako"
  # Declared explicitly: the download URL interpolates `version`, so the
  # audit's URL-scan cannot be the source of truth for this formula.
  version "2.8.19"
  license "BSD-2-Clause"

  base = "https://github.com/tamatebako/tebako/releases/download/v#{version}"
  # Resource blocks instance_eval against the Resource, where `version`
  # is the (unset) resource version — interpolate the captured local.
  ver = version.to_s

  on_macos do
    on_arm do
      url "#{base}/tebako-#{version}-macos-arm64"
      sha256 "64a2a4db8f649bf8150e2096c4ffb60aed1d288aad6b2bbe17e4c80b5eab462d"
      resource "tebako-pkg" do
        url "#{base}/tebako-pkg-#{ver}-macos-arm64"
        sha256 "2d2f8ff53b80d3155516fa4fd68033f7863704a7a8f9bbf05f34a463d9e3ed54"
      end
      resource "tfs" do
        url "#{base}/tfs-#{ver}-macos-arm64"
        sha256 "f08ef323050496006f67b9e298960b0fc53123e53754326dc21e41937955dc7a"
      end
      resource "tebako-shim" do
        url "#{base}/tebako-shim-#{ver}-macos-arm64"
        sha256 "26ae7284fecbf7c86852ee959354736e3d5fa31abb971821819272a5c7e07d85"
      end
      resource "tebako-bootstrap" do
        url "#{base}/tebako-bootstrap-#{ver}-macos-arm64"
        sha256 "3571c4cf494df2b7bee1294b0b8c27857912102f330d9244317eff8bde0089ac"
      end
    end
    on_intel do
      url "#{base}/tebako-#{version}-macos-x86_64"
      sha256 "73ec8a0ff4cd919de7ca7f47f4c336256d25af6b3084834d49d91b234a5b7113"
      resource "tebako-pkg" do
        url "#{base}/tebako-pkg-#{ver}-macos-x86_64"
        sha256 "0bcf3f3ec288500269f441379163a3e74e80ec6482e08b719bc3f2d298419905"
      end
      resource "tfs" do
        url "#{base}/tfs-#{ver}-macos-x86_64"
        sha256 "29a51bf8ea8c426ac0365d370637eb968013508d8eec9a595352e7a2f4c0e08f"
      end
      resource "tebako-shim" do
        url "#{base}/tebako-shim-#{ver}-macos-x86_64"
        sha256 "8785cb22bc4033e7bfae4911d0aad9bcd9abbc59abba32c2e7962dbc83ebe061"
      end
      resource "tebako-bootstrap" do
        url "#{base}/tebako-bootstrap-#{ver}-macos-x86_64"
        sha256 "2dd3b899acf54de0c8310595bf526c03878e6913ebf14de5dfbe0fd41c310a87"
      end
    end
  end

  on_linux do
    on_arm do
      url "#{base}/tebako-#{version}-linux-gnu-arm64"
      sha256 "5b818947e68fac4655de44b137e9a3cbcf95f355b15b50df88e5570549002455"
      resource "tebako-pkg" do
        url "#{base}/tebako-pkg-#{ver}-linux-gnu-arm64"
        sha256 "10801e740d6c6a664f2ad8e8d18a15bae83d9e75a53936b014d0d431e3f90692"
      end
      resource "tfs" do
        url "#{base}/tfs-#{ver}-linux-gnu-arm64"
        sha256 "ad5a70ef4a84baaaee7411d65340c0dcc6fb43360f9e77872d42032fe30fe7a7"
      end
      resource "tebako-shim" do
        url "#{base}/tebako-shim-#{ver}-linux-gnu-arm64"
        sha256 "7fe1d85a8ecfb9ae638e53a5635a50ef848bd0ea1a72751f26da0e08e6f309da"
      end
      resource "tebako-bootstrap" do
        url "#{base}/tebako-bootstrap-#{ver}-linux-gnu-arm64"
        sha256 "10847ab49b864ee49740d05b44a1ec5415a728203553da1c0ed0325892598420"
      end
    end
    on_intel do
      url "#{base}/tebako-#{version}-linux-gnu-x86_64"
      sha256 "17d4e0c5d1208381049601a0616fe740e0d7694132ce34d2850cb019273fa239"
      resource "tebako-pkg" do
        url "#{base}/tebako-pkg-#{ver}-linux-gnu-x86_64"
        sha256 "b86874d1d695e6424def2fc275f26f73bc52947310926f80aa4e8473856e2784"
      end
      resource "tfs" do
        url "#{base}/tfs-#{ver}-linux-gnu-x86_64"
        sha256 "8585ac81c8caa609bed33ebc485cf4adbe94d1d6c81b56c22e9bd289eb1d6eca"
      end
      resource "tebako-shim" do
        url "#{base}/tebako-shim-#{ver}-linux-gnu-x86_64"
        sha256 "cacace502c103c43bd41f78960561e5226b0565185290a3cb36c08310f0a0703"
      end
      resource "tebako-bootstrap" do
        url "#{base}/tebako-bootstrap-#{ver}-linux-gnu-x86_64"
        sha256 "3a135d3ea56b81d7b424e27520edffcc10cb39bec71c254e2679c368bd7da14f"
      end
    end
  end

  def install
    bin.install "tebako-#{version}-#{OS.mac? ? "macos" : "linux-gnu"}-#{Hardware::CPU.arm? ? "arm64" : "x86_64"}" => "tebako"
    %w[tebako-pkg tfs tebako-shim tebako-bootstrap].each do |name|
      resource(name).stage do
        bin.install Dir["#{name}-#{version}-*"].first => name
      end
    end
  end

  # Seeding note (spec 37 §6): Homebrew runs the post-install phase
  # under a sandbox with HOME redirected to a throwaway directory — a
  # formula cannot write the user's real store by design, so the
  # official-registry seed is a caveats instruction, not a post-install
  # step. install.sh (the musl/no-brew path) runs `tebako setup`
  # itself, in the user's real shell.

  def caveats
    <<~EOS
      Complete setup (once, both idempotent):
        tebako setup                     # seeds the official payload registry
        tebako-shim install-shell        # puts payload shims on your PATH
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
