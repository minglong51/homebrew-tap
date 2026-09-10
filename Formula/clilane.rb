class Clilane < Formula
  include Language::Python::Shebang

  desc "Run CLI agents and long tasks in tmux-backed lanes with crash-safe identity"
  homepage "https://github.com/minglong51/clilane"
  url "https://github.com/minglong51/clilane/releases/download/v0.11.1/clilane-0.11.1.tar.gz"
  sha256 "610da1876007afddb55bd7bc0f7ce5c7815bf41a629d8c722e9f22422c8c1795"
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
