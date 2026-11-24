{ inputs, ... }:
{
  flake.homeConfigurations."staffa" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;

    modules = [
      inputs.self.modules.homeManager.tihdizer-starship

      {
        home.username = "tihdizer";
        home.homeDirectory = "/home/tihdizer";
        home.stateVersion = "26.05";
      }
    ];
  };
}
