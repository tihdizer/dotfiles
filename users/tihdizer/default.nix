{ inputs, ... }:
{
  flake-file.inputs = {
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.tihdizer = {
    imports =
      (with inputs.self.modules.homeManager; [
        tihdizer-niri
        tihdizer-userdirs
        tihdizer-git
        tihdizer-github
        tihdizer-packages
        tihdizer-starship
        tihdizer-mime

        sops
        copyq
        dev
        firefox
        chromium
        chrome
        bottom
        yazi
        mpv
        obs
        scrcpy
        nixcord
        shell
        television
        jcode
        usb
        bluetooth
        ssh
        wallpaper
        lab-ubuntu
        torlink
        fuzzel
        anki
        aven
        telegram
        mako
        psysonic
      ])
      ++ [
        inputs.niri.homeModules.niri
      ];

    home.username = "tihdizer";
    home.homeDirectory = "/home/tihdizer";
    home.pointerCursor.enable = true;
    home.stateVersion = "26.05";
  };
}
