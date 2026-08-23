class Clilane < Formula
  include Language::Python::Shebang

  desc "Run CLI agents and long tasks in tmux-backed lanes with crash-safe identity"
  homepage "https://github.com/minglong51/clilane"
  url "https://github.com/minglong51/clilane/releases/download/v0.5.0/clilane-0.5.0.tar.gz"
  sha256 "19fd99623715ab93743fe05d65ffac06835df81d28e66a57dff48f2cbf5d4e6d"
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
