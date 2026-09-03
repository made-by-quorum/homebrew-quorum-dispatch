# Builds `qd` from made-by-quorum/quorum-dispatch over plain https — no
# ssh-agent, no repo access, nothing to authenticate.
#
# That repo carries no tags yet, so `url` pins a commit tarball and `version` is
# stated by hand (it is what `qd --version` reports; the crate version is
# 0.0.0). To ship a newer main: bump the url + sha256, and add/increment
# `revision` so Homebrew sees an upgrade even though `version` did not move.
#
# TWO binaries, ONE pin: `qd` and `qw`. `qw` is the lane worker qd spawns over
# stdio for every session operation, built from this same checkout so the pair
# is same-commit by construction — their wire protocol version-handshakes and
# refuses a mismatch. Both must land in the same directory: qd resolves qw as a
# sibling of its own executable and never via PATH, so a stray qw from another
# install can never be picked up.
class QuorumDispatch < Formula
  desc "Session engine for orchestrating Claude Code sessions"
  homepage "https://github.com/made-by-quorum/quorum-dispatch"
  url "https://github.com/made-by-quorum/quorum-dispatch/archive/15cdb43d9e90e46530ca6c6d0d46869772af484b.tar.gz"
  version "0.1.0"
  sha256 "ef45d4eb7a828cc56b0b47b19d63fe352f6b042fb27c582ecae445989eb39a58"
  license "Apache-2.0"
  head "https://github.com/made-by-quorum/quorum-dispatch.git", branch: "main"

  depends_on "rust" => :build

  def install
    # --bin on both: `quorum-dispatch` also carries test/dev bins that are not
    # part of the package. Sharing one target dir keeps the second build to
    # qw's own link rather than a full rebuild of the shared dependency tree.
    ENV["CARGO_TARGET_DIR"] = buildpath/"target"
    system "cargo", "install", *std_cargo_args(path: "crates/dispatch"), "--bin", "qd"
    system "cargo", "install", *std_cargo_args(path: "crates/quorum-qw"), "--bin", "qw"
  end

  def caveats
    "Run `qd setup` to finish setup."
  end

  test do
    assert_match(/^\d+\.\d+\.\d+$/, shell_output("#{bin}/qd --version").strip)
    system bin/"qd", "--help"

    # qw must be beside qd, and staged as a release build — the same probe
    # `qrm doctor` uses. Catches both ways this formula can regress.
    assert_path_exists bin/"qw"
    assert_equal "release", shell_output("#{bin}/qw build-profile").strip
  end
end
