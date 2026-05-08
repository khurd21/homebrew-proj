class Proj < Formula
  desc "Open a configured git project in your editor"
  homepage "https://github.com/khurd21/proj"
  url "file:///Users/kylehurd/Workplace/proj", using: :git, branch: "main"
  version "0.1.0"

  depends_on "cmake" => :build
  depends_on "cli11"
  depends_on "yaml-cpp"

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"

    libexec.install "build/proj"

    (zsh_completion/"_proj").write <<~EOS
      #compdef proj

      _proj() {
        local context state line
        typeset -A opt_args
        local -a projects
        projects=("${(@f)$(proj --list-projects 2>/dev/null)}")

        _arguments -C \
          '--list-projects[List configured git repositories]' \
          '--view-settings[Print configured scan directories and editor]' \
          '--add-path[Add a scan directory path to config/proj.yaml]:path:_files -/' \
          '--remove-path=[Remove a scan directory path from config/proj.yaml (omit value for interactive mode)]::path:_files -/' \
          '--clear-paths[Clear all scan directory paths from config/proj.yaml]' \
          '--set-editor[Set editor in config/proj.yaml]:editor:(vscode)' \
          '1:project name:->project'

        case $state in
          project)
            _describe -t projects 'project' projects
            ;;
        esac
      }

      compdef _proj proj
    EOS

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
    output = shell_output("#{bin}/proj --view-settings")
    assert_match "Settings{", output
  end
end
