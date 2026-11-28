{ ... }:
let
  hmModule =
    {
      config,
      options,
      lib,
      pkgs,
      ...
    }:
    {
      programs.zellij = {
        enable = true;
        package = pkgs.zellij;
      };

      programs.zsh.initContent = lib.mkAfter ''
        if [[ -z "$ZELLIJ" && -n "$PS1" && -z "$SSH_CONNECTION" ]]; then
          WS=""
          if [[ -n "$NIRI_SOCKET" ]] && command -v niri >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
            WS="$(niri msg -j workspaces 2>/dev/null | jq -r 'first(.[] | select(.is_focused == true) | (.name // (.idx | tostring))) // empty')"
          fi
          [[ -z "$WS" ]] && WS="main"
          exec zellij attach -c "$WS"
        fi
      '';

      programs.fish.interactiveShellInit = lib.mkAfter ''
        if status is-interactive; and not set -q ZELLIJ; and test -z "$SSH_CONNECTION"
          set -l ws ""
          if set -q NIRI_SOCKET; and command -q niri; and command -q jq
            set ws (niri msg -j workspaces 2>/dev/null | jq -r 'first(.[] | select(.is_focused == true) | (.name // (.idx | tostring))) // empty')
          end
          test -z "$ws"; and set ws "main"
          exec zellij attach -c "$ws"
        end
      '';

      xdg.configFile."zellij/config.kdl" = {
        text = ''
          default_layout "compact"
          pane_frames false
          simplified_ui true
          auto_layout true
          copy_on_select true
          copy_clipboard "system"
          show_release_notes false
          scroll_buffer_size 50000
          scrollback_editor "${pkgs.neovim}/bin/nvim"
        '';
      };
    };
in
{
  flake.modules.nixos.zellij =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.zellij ];
    };

  flake.modules.homeManager.zellij = hmModule;
}
