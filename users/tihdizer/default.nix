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
        tihdizer-packages
        tihdizer-starship
        tihdizer-mime

        sops
        copyq
        dev
        firefox
        chrome
        chrome-server
        chromium
        bottom
        yazi
        mpv
        obs
        scrcpy
        nixcord
        shell
        television
        omniroute
        jcode
        nirimap
        niri-sidebar
        usb
        bluetooth
        ssh
        wallpaper
        lab-ubuntu
        n8n
        torlink
        fuzzel
        anki
        aven
        telegram
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
