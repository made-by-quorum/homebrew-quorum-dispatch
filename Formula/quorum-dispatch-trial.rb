# TRIAL of installing prebuilt qd binaries from this tap, binaries only (no
# source is published). Not a release: this formula and the prerelease it
# points at are deleted once the trial is done. The supported formula is
# quorum-dispatch.rb, which this does not change.
#
# TWO binaries, ONE release: `qd` and `qw`. `qw` is the lane worker qd spawns
# over stdio for every session operation, built from the same commit so the
# pair is same-commit by construction; their wire protocol version-handshakes
# and refuses a mismatch. Both land in the same directory: qd resolves qw as a
# sibling of its own executable and never via PATH.
#
# Binaries exist for Apple Silicon Macs and x86_64 Linux (glibc 2.39 or newer)
# only. Any other platform has nothing to install from this trial.
class QuorumDispatchTrial < Formula
  desc "Session engine for orchestrating Claude Code sessions (trial build)"
  homepage "https://github.com/made-by-quorum/homebrew-quorum-dispatch"
  version "0.5.0-rc.1"

  on_macos do
    on_arm do
      url "https://github.com/made-by-quorum/homebrew-quorum-dispatch/releases/download/v0.5.0-rc.1/quorum-dispatch-v0.5.0-rc.1-aarch64-apple-darwin.tar.gz"
      sha256 "5669836d8aa30669ff09798b9fee72842acaf3fa84b810ca7ea7c2c5b85ef512"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/made-by-quorum/homebrew-quorum-dispatch/releases/download/v0.5.0-rc.1/quorum-dispatch-v0.5.0-rc.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "c6cde74e84d4e6c7165e81e0aa3da1913751e261300fa66538b1cf82531145d4"
    end
  end

  conflicts_with "quorum-dispatch", because: "both install qd and qw"

  def install
    # A binary tarball: qd and qw at the top level, nothing else.
    bin.install "qd", "qw"
  end

  def caveats
    "Run `qd setup` to finish setup."
  end

  test do
    # `qd --version` prints `X.Y.Z (sha)`; the version leads.
    assert_match(/^\d+\.\d+\.\d+/, shell_output("#{bin}/qd --version").strip)
    system bin/"qd", "--help"

    # qw must be beside qd, and staged as a release build, the same probe
    # `qrm doctor` uses.
    assert_path_exists bin/"qw"
    assert_equal "release", shell_output("#{bin}/qw build-profile").strip
  end
end
