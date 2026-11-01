class Clilane < Formula
  include Language::Python::Shebang

  desc "Run CLI agents and long tasks in tmux-backed lanes with crash-safe identity"
  homepage "https://github.com/minglong51/clilane"
  url "https://github.com/minglong51/clilane/releases/download/v0.14.2/clilane-0.14.2.tar.gz"
  sha256 "d0294db491db7b5ee26a12a70ed8516f44940a322f8dae1879ae70d1d5fbe707"
  license "MIT"

  depends_on "python@3.14"
  depends_on "tmux"

  def install
    bin.install "bin/clilane"
    rewrite_shebang detected_python_shebang, bin/"clilane"
  end

  test do
    ENV["CLILANE_STATE_HOME"] = (testpath/"state").to_s
    ENV["CLILANE_TMUX_SOCKET"] = "clilane-test-#{Process.pid}"
    ENV["TMUX_TMPDIR"] = ENV.fetch("TMPDIR")

    assert_match "clilane #{version}", shell_output("#{bin}/clilane --version")
    system bin/"clilane", "run", "brew-test", "-C", testpath.to_s, "--",
           "/bin/sh", "-c", "printf 'clilane-ok\\n'"
    system bin/"clilane", "wait", "--timeout", "10", "brew-test"
    assert_match "clilane-ok", shell_output("#{bin}/clilane read --all brew-test")
    system bin/"clilane", "rm", "brew-test"
  ensure
    quiet_system bin/"clilane", "rm", "--force", "brew-test"
  end
end
