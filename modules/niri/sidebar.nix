{ inputs, ... }:
let
  build = pkgs: pkgs.rustPlatform.buildRustPackage {
    pname = "niri-sidebar";
    version = "unstable";
    src = inputs.niri-sidebar;

    cargoHash = "sha256-zZlfwAxWE1ZZy6k7QoBOamCGigGShd89sD27vfvgR00=";
  };

  makeConfig = ''
    [geometry]
    width = 633
    height = 353
    gap = 6

    [margins]
    top = 6
    right = 2
    left = 2
    bottom = 6

    [interaction]
    position = "left"
    peek = 0
    focus_peek = 128
    sticky = true

    [[window_rule]]
    title = "(?i)^picture[- ]in[- ]picture$"
    auto_add = true

    [[window_rule]]
    app_id = "^org\\.telegram\\.desktop$"
    height = 480
  '';
in
{
  flake-file.inputs = {
    niri-sidebar = {
      url = "github:Vigintillionn/niri-sidebar";
      flake = false;
    };
  };

  flake.modules.nixos.niri-sidebar =
    { pkgs, ... }:
    {
      environment.systemPackages = [ (build pkgs) ];
      environment.etc."xdg/niri-sidebar/config.toml".text = makeConfig;
    };

  flake.modules.homeManager.niri-sidebar =
    { pkgs, ... }:
    {
      home.packages = [ (build pkgs) ];
      xdg.configFile."niri-sidebar/config.toml".text = makeConfig;
      programs.niri.settings.spawn-at-startup = [
        { sh = "niri-sidebar listen"; }
      ];
    };
}
