# frozen_string_literal: true

# The tebako CLI formula (spec 16 §3.1): installs the five tebako
# binaries (tebako, tfs, tebako-pkg, tebako-shim, tebako-bootstrap) per
# platform. sha256s are the release SHA256SUMS of v2.8.59 (verified at
# fill time).
class Tebako < Formula
  desc "Package, sign, and run stitched tebako packages and payload slices"
  homepage "https://github.com/tamatebako/tebako"
  # Declared explicitly: the download URL interpolates `version`, so the
  # audit's URL-scan cannot be the source of truth for this formula.
  version "2.8.59"
  license "BSD-2-Clause"

  base = "https://github.com/tamatebako/tebako/releases/download/v#{version}"
  # Resource blocks instance_eval against the Resource, where `version`
  # is the (unset) resource version — interpolate the captured local.
  ver = version.to_s

  on_macos do
    on_arm do
      url "#{base}/tebako-#{version}-macos-arm64"
      sha256 "80c1654bb3be4c95c102ba916edbf67860949b4de6d47d418918f89990aef10c"
      resource "tebako-pkg" do
        url "#{base}/tebako-pkg-#{ver}-macos-arm64"
        sha256 "902daed3a0737d8c84a3fbcfb1d4dbf2578e7bc437a2f9dbbcf18380c4fc7433"
      end
      resource "tfs" do
        url "#{base}/tfs-#{ver}-macos-arm64"
        sha256 "3161f025cd60446bca8484f422cbcb0e717e988c9f51e14b9af9e1c70d294b77"
      end
      resource "tebako-shim" do
        url "#{base}/tebako-shim-#{ver}-macos-arm64"
        sha256 "2a5b7525126c3996d9ad4047f250f22bab0dbbef9420d08d89b6305b35230950"
      end
      resource "tebako-bootstrap" do
        url "#{base}/tebako-bootstrap-#{ver}-macos-arm64"
        sha256 "471ec92b7d2952c75bb75c7fa6b400cd90880187e98f78c2ffda591443317a8b"
      end
    end
    on_intel do
      url "#{base}/tebako-#{version}-macos-x86_64"
      sha256 "4a2765cdd7ac9beb4f4a250e58fbde0bd7d7b4c8efc7ada76c9452ccb8a8c6ac"
      resource "tebako-pkg" do
        url "#{base}/tebako-pkg-#{ver}-macos-x86_64"
        sha256 "454a714d4f5657333ff6c886218d1a792935106636079476598fea8ec5b3dac3"
      end
      resource "tfs" do
        url "#{base}/tfs-#{ver}-macos-x86_64"
        sha256 "100c267f9cea4d159a9bb5047172997d720daf9d6b20136df457a4540169c396"
      end
      resource "tebako-shim" do
        url "#{base}/tebako-shim-#{ver}-macos-x86_64"
        sha256 "855eee04b96cdf579eac898506c81693a0369dca465c00d372272f6bfefca961"
      end
      resource "tebako-bootstrap" do
        url "#{base}/tebako-bootstrap-#{ver}-macos-x86_64"
        sha256 "25cf72bd4023194e82188be2ec11aff00131cfc14d5860806bb7d24c922125ef"
      end
    end
  end

  on_linux do
    on_arm do
      url "#{base}/tebako-#{version}-linux-gnu-arm64"
      sha256 "a16f0eee61f3681731203b3d8a431fff999d05672312e4cf0e8ab49553076a72"
      resource "tebako-pkg" do
        url "#{base}/tebako-pkg-#{ver}-linux-gnu-arm64"
        sha256 "99a952a343c1045342be8d7ba1b1cd5fbb99bd82d072bdac69bc1fa689bb1489"
      end
      resource "tfs" do
        url "#{base}/tfs-#{ver}-linux-gnu-arm64"
        sha256 "ecb6738af4321e1c33ecce688a12ca5b424905d1540409d88c0b1f52d8bb763f"
      end
      resource "tebako-shim" do
        url "#{base}/tebako-shim-#{ver}-linux-gnu-arm64"
        sha256 "594cce0388ea2faa395126ea5d68da89852028c9c4262e21a1d745d36fdf3fa2"
      end
      resource "tebako-bootstrap" do
        url "#{base}/tebako-bootstrap-#{ver}-linux-gnu-arm64"
        sha256 "9d04c41222bc6eff74fc2fcdca176469966d4cdbe4bc3a7a0d879772c3cf2148"
      end
    end
    on_intel do
      url "#{base}/tebako-#{version}-linux-gnu-x86_64"
      sha256 "27643e2e7a3a4816890cd26ec747eb3eabfdd78780e935874cdd6a291ed8a629"
      resource "tebako-pkg" do
        url "#{base}/tebako-pkg-#{ver}-linux-gnu-x86_64"
        sha256 "bed9987579e80705ad75bec9d9d8bba3f5b10a39ced2579c113b25e3c0d5c67a"
      end
      resource "tfs" do
        url "#{base}/tfs-#{ver}-linux-gnu-x86_64"
        sha256 "aad966bcde163ff73361c88254b6882be0192f3947dc0f68849df4ad1117c0df"
      end
      resource "tebako-shim" do
        url "#{base}/tebako-shim-#{ver}-linux-gnu-x86_64"
        sha256 "74101e02b259d99fc51dbd84a46f08fae675f89d66ee80caaffdc8dc2a2f5f39"
      end
      resource "tebako-bootstrap" do
        url "#{base}/tebako-bootstrap-#{ver}-linux-gnu-x86_64"
        sha256 "5180cdae66ed0d40a6627d1fae17036ddd35625d754aafd0e6956aa974b3225f"
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
