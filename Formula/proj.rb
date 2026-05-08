class Proj < Formula
  desc "Open a configured git project in your editor"
  homepage "https://github.com/kylehurd/proj"
  url "file:///Users/kylehurd/Workplace/proj", using: :git, branch: "main"
  version "0.1.0"

  depends_on "cmake" => :build
  depends_on "cli11"
  depends_on "yaml-cpp"

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"

    libexec.install "build/proj"

    completion = Utils.safe_popen_read(buildpath/"build/proj", "--completion", "zsh")
    (zsh_completion/"_proj").write completion

    (pkgshare/"config").install "config/proj.yaml"

    (bin/"proj").write <<~EOS
      #!/bin/bash
      set -euo pipefail

      config_root="#{HOMEBREW_PREFIX}/var/proj"
      mkdir -p "$config_root/config"

      if [[ ! -f "$config_root/config/proj.yaml" ]]; then
        cp "#{pkgshare}/config/proj.yaml" "$config_root/config/proj.yaml"
      fi

      cd "$config_root"
      exec "#{libexec}/proj" "$@"
    EOS
  end

  def post_install
    (var/"proj/config").mkpath
    return if (var/"proj/config/proj.yaml").exist?

    cp pkgshare/"config/proj.yaml", var/"proj/config/proj.yaml"
  end

  test do
    output = shell_output("#{bin}/proj --completion zsh")
    assert_match "#compdef proj", output
  end
end
