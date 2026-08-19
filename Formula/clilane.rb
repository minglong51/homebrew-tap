class Clilane < Formula
  include Language::Python::Shebang

  desc "Manage CLI agents and terminal tasks in background lanes"
  homepage "https://github.com/minglong51/clilane"
  url "https://github.com/minglong51/clilane/releases/download/v0.2.0/clilane-0.2.0.tar.gz"
  sha256 "cdaf2d1fc28cbf233e85d0a223403413235ab494de5df183b79dc1573428e289"
  license "MIT"

  depends_on :macos
  depends_on "python@3.14"
  depends_on "tmux"

  def install
    bin.install "bin/clilane"
    rewrite_shebang detected_python_shebang, bin/"clilane"
  end

  test do
    ENV["CLILANE_STATE_HOME"] = (testpath/"state").to_s
    ENV["CLILANE_TMUX_SOCKET"] = "clilane-test-#{Process.pid}"

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
