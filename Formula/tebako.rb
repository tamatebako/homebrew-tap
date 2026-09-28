# frozen_string_literal: true

# The tebako CLI formula (spec 16 §3.1): installs the five tebako
# binaries (tebako, tfs, tebako-pkg, tebako-shim, tebako-bootstrap) per
# platform. sha256s are the release SHA256SUMS of v2.8.18 (verified at
# fill time).
class Tebako < Formula
  desc "Package, sign, and run stitched tebako packages and payload slices"
  homepage "https://github.com/tamatebako/tebako"
  # Declared explicitly: the download URL interpolates `version`, so the
  # audit's URL-scan cannot be the source of truth for this formula.
  version "2.8.18"
  license "BSD-2-Clause"

  base = "https://github.com/tamatebako/tebako/releases/download/v#{version}"
  # Resource blocks instance_eval against the Resource, where `version`
  # is the (unset) resource version — interpolate the captured local.
  ver = version.to_s

  on_macos do
    on_arm do
      url "#{base}/tebako-#{version}-macos-arm64"
      sha256 "30e341ce88e95e81af2c80200936f5fe66b4cc2f8318383ff8b68b05f6665b50"
      resource "tebako-pkg" do
        url "#{base}/tebako-pkg-#{ver}-macos-arm64"
        sha256 "1a08522984286852007f99e6025f3d73f091fc0f2377111512651d4aa242cc34"
      end
      resource "tfs" do
        url "#{base}/tfs-#{ver}-macos-arm64"
        sha256 "3d536d82849bcd87848a9197d6869018af55812cb0095e920e8aa32e22d05387"
      end
      resource "tebako-shim" do
        url "#{base}/tebako-shim-#{ver}-macos-arm64"
        sha256 "6aca42429882f28ff8618d60ed5013a55178eed7cf242c44f860d643a2514597"
      end
      resource "tebako-bootstrap" do
        url "#{base}/tebako-bootstrap-#{ver}-macos-arm64"
        sha256 "b1bbefbd29f34b11e39117ab532e2e83a784465a17f0ac7cb51ee794d6a29c9a"
      end
    end
    on_intel do
      url "#{base}/tebako-#{version}-macos-x86_64"
      sha256 "f0aef0aaf3ff14cf57de4c02ccd500a6101a28c85f081df4a3d4c5f0454ffb6b"
      resource "tebako-pkg" do
        url "#{base}/tebako-pkg-#{ver}-macos-x86_64"
        sha256 "07678647f37038c8d5191cb0c2b8ba17dab0acc8d7332bc2f1c49b56b5ad6fa3"
      end
      resource "tfs" do
        url "#{base}/tfs-#{ver}-macos-x86_64"
        sha256 "838e3c296027d68e59b1057683d231df93a9c6f7ed3f27815c83b97cb440a4e1"
      end
      resource "tebako-shim" do
        url "#{base}/tebako-shim-#{ver}-macos-x86_64"
        sha256 "7562f66076f7abf8f7ce1f81a5b3ae89b337f83f196a3d61e2bc9d31e2103988"
      end
      resource "tebako-bootstrap" do
        url "#{base}/tebako-bootstrap-#{ver}-macos-x86_64"
        sha256 "7f4dce4271d6be1807fdd0db6da7614022717ddaf5256eedbcd5be9cd0aa43be"
      end
    end
  end

  on_linux do
    on_arm do
      url "#{base}/tebako-#{version}-linux-gnu-arm64"
      sha256 "ca5fdf8ddb24a33ad3e538e00b80fccd1a17edb66462ec375bcbb340d4a68e11"
      resource "tebako-pkg" do
        url "#{base}/tebako-pkg-#{ver}-linux-gnu-arm64"
        sha256 "b6f15d1267b9cc8c7f306daa209266d7fb49565686c632ca730923d94ed13add"
      end
      resource "tfs" do
        url "#{base}/tfs-#{ver}-linux-gnu-arm64"
        sha256 "9c152c718e0dcf329f709a8259d4eefe2aead454045f417f382736e20583c09e"
      end
      resource "tebako-shim" do
        url "#{base}/tebako-shim-#{ver}-linux-gnu-arm64"
        sha256 "1247f21ec70f55537fc359eb0b5b1df4a61642910d73f6ceadc2cb98091d9ff3"
      end
      resource "tebako-bootstrap" do
        url "#{base}/tebako-bootstrap-#{ver}-linux-gnu-arm64"
        sha256 "ac2d2b63fde4cd372d90909fce08d1aaf79178e1724a58e61d4860625bae8f28"
      end
    end
    on_intel do
      url "#{base}/tebako-#{version}-linux-gnu-x86_64"
      sha256 "9c9c9b12be99184f800097bba2c7ab0fd4fc16574507eec605327e325c607074"
      resource "tebako-pkg" do
        url "#{base}/tebako-pkg-#{ver}-linux-gnu-x86_64"
        sha256 "634d118c74d7e58bf33099ba81d42ed0414e2a196f64836e3b760de798b554d2"
      end
      resource "tfs" do
        url "#{base}/tfs-#{ver}-linux-gnu-x86_64"
        sha256 "026a6d381daa0bde64a8d638b45964eec240fb77d6a6c2e00fc5123404020d16"
      end
      resource "tebako-shim" do
        url "#{base}/tebako-shim-#{ver}-linux-gnu-x86_64"
        sha256 "828110100e2395d1e77bd7b8bb2a56fd3d4d2a13d8986b9ddf3e1bb258938cb4"
      end
      resource "tebako-bootstrap" do
        url "#{base}/tebako-bootstrap-#{ver}-linux-gnu-x86_64"
        sha256 "9aaef8dc9ecc2b56651cf74b34842a81f23462284480b5f62c289b433aaafc10"
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
