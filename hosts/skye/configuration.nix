{ inputs, ... }:
{
  flake.modules.nixos.skye = {
    imports = with inputs.self.modules.nixos; [
      #= Host
      skye-hardware
      skye-disko
      skye-preservation
      skye-system
      skye-locales
      skye-users
      system-default
      home-manager

      #= Shell
      shell
      sops

      #= Dev
      jcode
      herdr
      github

      #= Networking
      networkmanager
      firewall
      dae
      throne
      ssh
      mpv

      #= Virtualization
      qemu
      podman
      windows
      docker

      #= TODO: Desktop
      programs-desktop-niri
      sunshine
      chromium

      #= Gaming
      steam
      # prism-launcher
    ];

    networking.hostName = "skye";

    system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    home-manager.users.tihdizer = inputs.self.modules.homeManager.tihdizer;
  };
}
