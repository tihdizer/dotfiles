{ inputs, ... }:
{
  flake.homeConfigurations."staffa" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;

    modules = [
      inputs.self.modules.homeManager.tihdizer-starship
      inputs.self.modules.homeManager.staffa-packages

      {
        targets.genericLinux.enable = true;
        home.username = "tihdizer";
        home.homeDirectory = "/home/tihdizer";
        home.stateVersion = "26.05";
        home.sessionVariables = {
          TERMINFO_DIRS = "$HOME/.nix-profile/share/terminfo:$HOME/.local/state/nix/profiles/profile/share/terminfo:/etc/terminfo:/lib/terminfo:/usr/share/terminfo";
        };
        programs.zsh.envExtra = ''
          export TERMINFO_DIRS="$HOME/.nix-profile/share/terminfo:$HOME/.local/state/nix/profiles/profile/share/terminfo:/etc/terminfo:/lib/terminfo:/usr/share/terminfo''${TERMINFO_DIRS:+:}$TERMINFO_DIRS"
        '';
      }
    ];
  };
}
