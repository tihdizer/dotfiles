{ inputs, ... }:
{
  flake-file.inputs = {
    yazi = {
      url = "github:sxyazi/yazi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.yazi =
    { pkgs, ... }:
    {
      programs.yazi = {
        enable = true;
        package = inputs.yazi.packages.${pkgs.stdenv.hostPlatform.system}.default or pkgs.yazi;
      };

      environment.systemPackages = with pkgs; [
        file
        fzf
        ripgrep
        fd
        zoxide
        jq
        poppler-utils
        ffmpeg
        _7zz
        tabiew
      ];
    };

  flake.modules.homeManager.yazi =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      yazi-wrapper = pkgs.writeShellScriptBin "yazi-wrapper" ''
        set -e

        multiple="$1"
        directory="$2"
        save="$3"
        path="$4"
        out="$5"

        if [[ "$path" =~ ^file://(.*) ]]; then
          path="''${BASH_REMATCH[1]}"
          path="''${path#localhost}"
          printf -v path '%b' "''${path//%/\\x}"
        fi

        if [ -n "$path" ] && [ -e "$path" ]; then
          target="$path"
        elif [ -n "$path" ] && [ -d "$(dirname "$path")" ]; then
          target="$(dirname "$path")"
        else
          target="$HOME"
        fi

        if [ "$save" = "1" ]; then
          set -- --chooser-file="$out" "$target"
        elif [ "$directory" = "1" ]; then
          set -- --chooser-file="$out" --cwd-file="$out.1" "$target"
        else
          set -- --chooser-file="$out" "$target"
        fi

        ${lib.getExe pkgs.kitty} \
          --class=file_chooser \
          -e ${lib.getExe config.programs.yazi.package} \
          "$@"

        if [ "$directory" = "1" ]; then
          if [ ! -s "$out" ] && [ -s "$out.1" ]; then
            cat "$out.1" > "$out"
            rm -f "$out.1"
          else
            rm -f "$out.1"
          fi
        fi
      '';

      yazi-floating = pkgs.writeShellScriptBin "yazi-floating" ''
        paths=()
        for arg in "$@"; do
          [ -z "$arg" ] && continue
          if [[ "$arg" =~ ^file://(.*) ]]; then
            p="''${BASH_REMATCH[1]}"
            p="''${p#localhost}"
            printf -v p '%b' "''${p//%/\\x}"
          else
            p="$arg"
          fi
          paths+=("$p")
        done

        if [ ''${#paths[@]} -gt 0 ]; then
          exec ${lib.getExe pkgs.kitty} \
            --class=yazi-floating \
            -e ${lib.getExe config.programs.yazi.package} \
            "''${paths[@]}"
        else
          exec ${lib.getExe pkgs.kitty} \
            --class=yazi-floating \
            -e ${lib.getExe config.programs.yazi.package}
        fi
      '';

      yazi-filemanager-wrapper = pkgs.writeShellScriptBin "yazi-filemanager-wrapper" ''
        method="$1"
        shift

        paths=()
        for arg in "$@"; do
          [ -z "$arg" ] && continue
          if [[ "$arg" =~ ^file://(.*) ]]; then
            p="''${BASH_REMATCH[1]}"
            p="''${p#localhost}"
            printf -v p '%b' "''${p//%/\\x}"
          else
            p="$arg"
          fi
          paths+=("$p")
        done

        if [ ''${#paths[@]} -gt 0 ]; then
          exec ${yazi-floating}/bin/yazi-floating "''${paths[@]}"
        else
          exec ${yazi-floating}/bin/yazi-floating
        fi
      '';
    in
    {
      programs.yazi = {
        enable = true;
        package = inputs.yazi.packages.${pkgs.stdenv.hostPlatform.system}.default;
        enableBashIntegration = true;
        enableZshIntegration = true;
        enableFishIntegration = true;

        plugins = {
          mount = pkgs.yaziPlugins.mount.overrideAttrs (old: {
            postPatch =
              (old.postPatch or "")
              + ''
                substituteInPlace mount.yazi/main.lua \
                  --replace-fail ':type(ui.Border.ROUNDED)' ':set("rounded")'
              '';
          });
          smart-enter = pkgs.yaziPlugins.smart-enter;
          ouch = pkgs.yaziPlugins.ouch;
          piper = pkgs.yaziPlugins.piper;
          git = {
            package = pkgs.yaziPlugins.git;
            setup = true;
          };
          lazygit = pkgs.yaziPlugins.lazygit;
          open-git-remote = pkgs.yaziPlugins.mkYaziPlugin {
            pname = "open-git-remote";
            version = "0-unstable-2026-05-12";
            src = pkgs.fetchFromGitHub {
              owner = "larry-oates";
              repo = "open-git-remote.yazi";
              rev = "72158d607c01b63bc4eb5ac6fc0dc0691b41ce8c";
              hash = "sha256-DGiGn5NveIGU0BikQ9U3vPL2R/qo1VA9ZfElOwl6qPk=";
            };
          };
          omni-trash = pkgs.yaziPlugins.mkYaziPlugin {
            pname = "omni-trash";
            version = "0-unstable-2026-09-20";
            src = pkgs.fetchFromGitHub {
              owner = "goon";
              repo = "omni-trash.yazi";
              rev = "3c2a9923673e0552a093afc4122473df1d427a93";
              hash = "sha256-heqqEWzJCoNt3CIJAEaWfqUX4J9BfVEw3OsU7Xjc17M=";
            };
            postPatch = ''
              substituteInPlace main.lua \
                --replace-fail ':type(ui.Border.ROUNDED)' ':set("rounded")'
            '';
          };
        };

        theme = {
          git = {
            unknown_sign = "";
            clean_sign = "";
            unstaged_sign = "~";
            staged_sign = "+";
            added_sign = "+";
            deleted_sign = "-";
            untracked_sign = "?";
            ignored_sign = "*";
            updated_sign = "=";
          };
        };

        settings = {
          preview = {
            image_delay = 0;
            max_width = 1920;
            max_height = 1080;
            image_quality = 90;
            image_filter = "lanczos3";
          };

          tasks = {
            suppress_preload = false;
            preload_workers = 4;
          };

          opener = {
            edit = [
              {
                run = "nvim %s";
                desc = "Neovim";
                block = true;
              }
            ];
            play = [
              {
                run = "mpv %s";
                desc = "MPV";
                orphan = true;
              }
              {
                run = "mediainfo %s1; echo 'Press enter to exit'; read _";
                desc = "Show media info";
                block = true;
              }
            ];
            office = [
              {
                run = "onlyoffice-desktopeditors %s";
                desc = "ONLYOFFICE";
                orphan = true;
              }
            ];
            readest = [
              {
                run = "readest %s";
                desc = "Readest";
                orphan = true;
              }
            ];
            imv = [
              {
                run = "imv %s";
                desc = "imv";
                orphan = true;
              }
            ];
            chromium = [
              {
                run = "chromium %s";
                desc = "Chromium";
                orphan = true;
              }
            ];
            firefox = [
              {
                run = "firefox %s";
                desc = "Firefox";
                orphan = true;
              }
            ];
            glow = [
              {
                run = "glow -p -w 0 %s";
                desc = "Glow";
                block = true;
              }
            ];
            tabiew = [
              {
                run = "tw %s";
                desc = "Tabiew";
                block = true;
              }
            ];
            tdf = [
              {
                run = "tdf %s";
                desc = "tdf";
                block = true;
              }
            ];
            reveal = [
              {
                run = "${yazi-floating}/bin/yazi-floating %s";
                desc = "Reveal";
                orphan = true;
              }
            ];
          };

          open = {
            prepend_rules = [
              {
                url = "*.{zip,rar,7z,7z.*,tar,tgz,tbz2,txz,gz,xz,zst,bz2}";
                use = [ "extract" "reveal" ];
              }
              {
                mime = "application/{vnd.openxmlformats-officedocument.*,msword,vnd.ms-*,vnd.oasis.opendocument.*,x-msword}";
                use = [ "office" "open" "reveal" ];
              }
              {
                url = "*.{doc,docx,odt,rtf,xls,xlsx,ods,ppt,pptx,odp}";
                use = [ "office" "open" "reveal" ];
              }
              {
                mime = "application/pdf";
                use = [ "tdf" "readest" "chromium" "firefox" "open" "reveal" ];
              }
              {
                url = "*.pdf";
                use = [ "tdf" "readest" "chromium" "firefox" "open" "reveal" ];
              }
              {
                mime = "text/markdown";
                use = [ "edit" "glow" "open" "reveal" ];
              }
              {
                url = "*.{md,markdown,mdown,mkd}";
                use = [ "edit" "glow" "open" "reveal" ];
              }
              {
                mime = "image/*";
                use = [ "imv" "chromium" "open" "reveal" ];
              }
              {
                mime = "{audio,video}/*";
                use = [ "play" "reveal" ];
              }
              {
                mime = "text/html";
                use = [ "chromium" "firefox" "edit" "open" "reveal" ];
              }
              {
                url = "*.{html,htm}";
                use = [ "chromium" "firefox" "edit" "open" "reveal" ];
              }
              {
                mime = "application/{json,ndjson,javascript,wine-extension-ini,xml,toml,yaml,x-yaml}";
                use = [ "edit" "chromium" "reveal" ];
              }
              {
                mime = "text/csv";
                use = [ "tabiew" "edit" "reveal" ];
              }
              {
                url = "*.csv";
                use = [ "tabiew" "edit" "reveal" ];
              }
              {
                mime = "text/tab-separated-values";
                use = [ "tabiew" "edit" "reveal" ];
              }
              {
                url = "*.tsv";
                use = [ "tabiew" "edit" "reveal" ];
              }
              {
                url = "*.{dsv,parquet,arrow,jsonl}";
                use = [ "tabiew" "edit" "reveal" ];
              }
              {
                mime = "text/*";
                use = [ "edit" "glow" "open" "reveal" ];
              }
            ];
          };

          plugin = {
            prepend_fetchers = [
              {
                url = "*";
                run = "git";
                group = "git";
              }
              {
                url = "*/";
                run = "git";
                group = "git";
              }
            ];

            prepend_previewers = [
              {
                url = "*.{zip,rar,7z,7z.*,tar,tgz,tbz2,txz,gz,xz,zst,bz2}";
                run = "archive";
              }
              {
                url = "*.csv";
                run = ''piper -- mlr --icsv --opprint --barred-unicode --right-align-numeric --ragged --lazy-quotes -C cat "$1"'';
              }
              {
                mime = "text/csv";
                run = ''piper -- mlr --icsv --opprint --barred-unicode --right-align-numeric --ragged --lazy-quotes -C cat "$1"'';
              }
              {
                url = "*.tsv";
                run = ''piper -- mlr --itsv --opprint --barred-unicode --right-align-numeric --ragged --lazy-quotes -C cat "$1"'';
              }
              {
                mime = "text/tab-separated-values";
                run = ''piper -- mlr --itsv --opprint --barred-unicode --right-align-numeric --ragged --lazy-quotes -C cat "$1"'';
              }
              {
                url = "*.html";
                run = ''piper -- w3m -dump -T text/html -cols "$w" "$1"'';
              }
              {
                url = "*.htm";
                run = ''piper -- w3m -dump -T text/html -cols "$w" "$1"'';
              }
              {
                mime = "text/html";
                run = ''piper -- w3m -dump -T text/html -cols "$w" "$1"'';
              }
              {
                url = "*.docx";
                run = ''piper -- pandoc --quiet -s -t plain --columns="$w" "$1"'';
              }
              {
                mime = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
                run = ''piper -- pandoc --quiet -s -t plain --columns="$w" "$1"'';
              }
              {
                url = "*.doc";
                run = ''piper -- catdoc -d utf-8 -m "$w" "$1"'';
              }
              {
                mime = "application/msword";
                run = ''piper -- catdoc -d utf-8 -m "$w" "$1"'';
              }
              {
                url = "*.odt";
                run = ''piper -- pandoc --quiet -s -t plain --columns="$w" "$1"'';
              }
              {
                mime = "application/vnd.oasis.opendocument.text";
                run = ''piper -- pandoc --quiet -s -t plain --columns="$w" "$1"'';
              }
              {
                url = "*.rtf";
                run = ''piper -- pandoc --quiet -s -t plain --columns="$w" "$1"'';
              }
              {
                mime = "application/rtf";
                run = ''piper -- pandoc --quiet -s -t plain --columns="$w" "$1"'';
              }
            ];
          };
        };

        keymap = {
          mgr.prepend_keymap = [
            {
              on = "l";
              run = "plugin smart-enter";
              desc = "Enter the child directory, or open the file";
            }
            {
              on = "M";
              run = "plugin mount";
              desc = "Mount device / disk";
            }
            {
              on = [ "g" "i" ];
              run = "plugin lazygit";
              desc = "Run lazygit";
            }
            {
              on = [ "g" "l" ];
              run = "plugin open-git-remote";
              desc = "Open git remote URL in browser";
            }
            {
              on = [ "g" "t" ];
              run = "plugin omni-trash";
              desc = "Open trash manager";
            }
            {
              on = "<A-y>";
              run = "shell -- cat %s | wl-copy";
              desc = "Copy contents of file(s) to clipboard";
            }
            {
              on = [ "g" "c" ];
              run = "cd ${config.home.homeDirectory}/dotfiles";
              desc = "Go to ~/dotfiles";
            }
            {
              on = [ "g" "d" ];
              run = "cd ${config.xdg.userDirs.download}";
              desc = "Go to downloads";
            }
            {
              on = "y";
              run = [
                ''shell -- for path in %s; do echo "file://$path"; done | wl-copy -t text/uri-list''
                "yank"
              ];
            }
            {
              on = "x";
              run = [
                ''shell -- for path in %s; do echo "file://$path"; done | wl-copy -t text/uri-list''
                "yank --cut"
              ];
            }
            {
              on = "<C-p>";
              run = ''shell -- wl-paste -t text/uri-list 2>/dev/null | tr -d "\r" | while IFS= read -r uri; do [ -z "$uri" ] && continue; if [[ "$uri" =~ ^file://(.*) ]]; then path="''${BASH_REMATCH[1]}"; printf -v path '%b' "''${path//%/\\x}"; else path="$uri"; fi; [ -e "$path" ] && cp -r -- "$path" .; done'';
            }
          ];
        };
      };

      home.sessionVariables = {
        GTK_USE_PORTAL = "1";
        QT_QPA_PLATFORMTHEME = lib.mkForce "xdgdesktopportal";
        TDESKTOP_USE_GTK_FILE_DIALOG = "1";
      };

      xdg.desktopEntries.yazi = {
        name = "Yazi";
        genericName = "File Manager";
        comment = "Terminal file manager";

        exec =
          "${yazi-floating}/bin/yazi-floating %U";

        icon = "yazi";

        terminal = false;
        type = "Application";

        categories = [
          "System"
          "FileManager"
          "FileTools"
        ];

        mimeType = [
          "inode/directory"
          "application/x-directory"
        ];
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "inode/directory" = [ "yazi.desktop" ];
          "application/x-directory" = [ "yazi.desktop" ];
        };
      };

      xdg.portal = {
        extraPortals = [ pkgs.xdg-desktop-portal-termfilechooser ];
        config = {
          common = {
            "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
          };
          niri = {
            "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
          };
        };
      };

      xdg.configFile."xdg-desktop-portal-termfilechooser/config" = {
        text = ''
          [filechooser]
          cmd=${yazi-wrapper}/bin/yazi-wrapper
          default_dir=$HOME
        '';
      };

      xdg.configFile."org.freedesktop.FileManager1.common/config" = {
        text = ''
          cmd=${yazi-filemanager-wrapper}/bin/yazi-filemanager-wrapper
        '';
      };

      systemd.user.services.file-manager-dbus = {
        Unit = {
          Description = "File Manager DBus Service";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          Type = "dbus";
          BusName = "org.freedesktop.FileManager1";
          ExecStart = "${pkgs.org-freedesktop-filemanager1-common}/libexec/file_manager_dbus";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      home.packages = with pkgs; [
        org-freedesktop-filemanager1-common # DBus file manager interface (ShowItems, ShowFolders)
        glow # Terminal markdown viewer / pager
        miller # Fast tabular data processor (CSV, TSV, JSON)
        tabiew # Lightweight terminal UI for viewing tabular data
        lazygit # Terminal UI for git
        _7zz # 7-Zip archiver (required by yazi for extraction)
        trash-cli # Trash manager
        ouch # Painless compression and decompression in the terminal
        w3m # Text-based web browser / HTML renderer
        pandoc # Document converter (docx, odt, etc.)
        catdoc # MS-Word (.doc) text extractor
        util-linux # Provides lsblk, eject for mount plugin
        ffmpeg # Multimedia framework
        poppler-utils # PDF rendering library (pdftoppm)
        tdf # Terminal PDF viewer
        fd # Fast find alternative
        file # File type detector
        jq # JSON processor
        ripgrep # Fast grep (rg)
        fzf # Fuzzy finder
        zoxide # Smart cd (z)
        resvg # SVG rasterizer
        imagemagick # Image manipulation
        bat # Cat clone with syntax highlighting
        lsd # Modern ls alternative
        ripdrag # Drag and drop utility
        wl-clipboard # Wayland clipboard
      ];
    };
}
