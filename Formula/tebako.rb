# frozen_string_literal: true

# The tebako CLI formula (spec 16 §3.1): installs the five tebako
# binaries (tebako, tfs, tebako-pkg, tebako-shim, tebako-bootstrap) per
# platform. sha256s are the release SHA256SUMS of v2.8.60 (verified at
# fill time).
class Tebako < Formula
  desc "Package, sign, and run stitched tebako packages and payload slices"
  homepage "https://github.com/tamatebako/tebako"
  # Declared explicitly: the download URL interpolates `version`, so the
  # audit's URL-scan cannot be the source of truth for this formula.
  version "2.8.60"
  license "BSD-2-Clause"

  base = "https://github.com/tamatebako/tebako/releases/download/v#{version}"
  # Resource blocks instance_eval against the Resource, where `version`
  # is the (unset) resource version — interpolate the captured local.
  ver = version.to_s

  on_macos do
    on_arm do
      url "#{base}/tebako-#{version}-macos-arm64"
      sha256 "19601037863f8950701ca891cd7a10b2dc9d0faa5ccfe1e5862469441be323a8"
      resource "tebako-pkg" do
        url "#{base}/tebako-pkg-#{ver}-macos-arm64"
        sha256 "35edf3ce716334a81da0eb79ba9a32cff943d2221ef193985a48375b0bca035a"
      end
      resource "tfs" do
        url "#{base}/tfs-#{ver}-macos-arm64"
        sha256 "ed33edca6102977ee3ff0267b1ba291af21010467a9f3f0483326e47a3be943a"
      end
      resource "tebako-shim" do
        url "#{base}/tebako-shim-#{ver}-macos-arm64"
        sha256 "21ac5ec405398de76ca1e13e0f909b8cff0bbc558d0b0eab199839322307869c"
      end
      resource "tebako-bootstrap" do
        url "#{base}/tebako-bootstrap-#{ver}-macos-arm64"
        sha256 "9652a31ba2b147c4ca53229b911ee6d89d02861a5a24ee1a618f6299b666b5bb"
      end
    end
    on_intel do
      url "#{base}/tebako-#{version}-macos-x86_64"
      sha256 "79c07944cbcacc8b8fd9bae0c9a7830ee008319829916d0bf01d1e8b0a9e7923"
      resource "tebako-pkg" do
        url "#{base}/tebako-pkg-#{ver}-macos-x86_64"
        sha256 "1fb89722272d8db453646a300ce33a30592e9f9a706ea3ab4bb0b674eef5dca2"
      end
      resource "tfs" do
        url "#{base}/tfs-#{ver}-macos-x86_64"
        sha256 "684b8757a08d5e493b7be5f9602421eaaeb8b09e006ba36fa492fbb88d159742"
      end
      resource "tebako-shim" do
        url "#{base}/tebako-shim-#{ver}-macos-x86_64"
        sha256 "01661fab3b68c1cd9b3f515296caf98a133dd3245fe80ab08b988d8b4a705bef"
      end
      resource "tebako-bootstrap" do
        url "#{base}/tebako-bootstrap-#{ver}-macos-x86_64"
        sha256 "79b2709b54f7f428c2b8e84b6f02ce7cd7c5e817ecc05a98302c9d577ddfd06b"
      end
    end
  end

  on_linux do
    on_arm do
      url "#{base}/tebako-#{version}-linux-gnu-arm64"
      sha256 "27f87d4d13feedc1a552350b409797582c7ab8cb9ce2e3d8681900fad6c3a347"
      resource "tebako-pkg" do
        url "#{base}/tebako-pkg-#{ver}-linux-gnu-arm64"
        sha256 "f10831ca724c8f1dc475a6a6018279f9c9945c707decf7e9c0a9086ce00291aa"
      end
      resource "tfs" do
        url "#{base}/tfs-#{ver}-linux-gnu-arm64"
        sha256 "ee0abbb566860a50358d493563a8a611a6db24bbff43aa3fdb27c88751f1b6d9"
      end
      resource "tebako-shim" do
        url "#{base}/tebako-shim-#{ver}-linux-gnu-arm64"
        sha256 "837a9c9b1c82ff3633aa8a4e1dbafea12498a7f93a54b9fdfcde5b2c72bc3ed3"
      end
      resource "tebako-bootstrap" do
        url "#{base}/tebako-bootstrap-#{ver}-linux-gnu-arm64"
        sha256 "5ae7e674f444eef1752f0060bd618f78bdc39c368f829868e8a5cfca0def9fac"
      end
    end
    on_intel do
      url "#{base}/tebako-#{version}-linux-gnu-x86_64"
      sha256 "7be77815a3b8077814e01029ee6cb44cec9a0ba9f51b54b7a4ec7a097b3de7ec"
      resource "tebako-pkg" do
        url "#{base}/tebako-pkg-#{ver}-linux-gnu-x86_64"
        sha256 "37aa1baedf27d6048537437ff7df570a5754ea0363a853eeee302ce0583cb63e"
      end
      resource "tfs" do
        url "#{base}/tfs-#{ver}-linux-gnu-x86_64"
        sha256 "299bf0537b9b292ad07792eacd81cb7a87e688f2bd770c771eed9117082d8762"
      end
      resource "tebako-shim" do
        url "#{base}/tebako-shim-#{ver}-linux-gnu-x86_64"
        sha256 "590b21358a5d8afde504cba9fb51e7f3129d9d38ff49ec6751b7d2ab049016fc"
      end
      resource "tebako-bootstrap" do
        url "#{base}/tebako-bootstrap-#{ver}-linux-gnu-x86_64"
        sha256 "201c1de1bcb4c084cf9d213566283d4d4bd48e8c15e5591e442886637e879332"
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
