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
      }
    ];
  };
}
