{ ... }:
{
  flake.modules.nixos.mull-hardware =
    { lib, modulesPath, ... }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [
        "virtio_net"
        "virtio_pci"
        "virtio_mmio"
        "virtio_blk"
        "virtio_scsi"
        "9p"
        "9pnet_virtio"
      ];

      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ ];
      boot.extraModulePackages = [ ];
      networking.useDHCP = lib.mkDefault false;

      systemd.network.enable = true;
      networking.useNetworkd = true;

      networking.nameservers = [
        "8.8.8.8"
        "8.8.4.4"
      ];

      systemd.network.networks."30-ens3" = {
        matchConfig.Name = "ens3";

        address = [
          "5.83.147.61/24"
        ];

        routes = [
          {
            Gateway = "5.83.147.1";
          }
        ];

        networkConfig = {
          DHCP = "no";
        };
      };

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
}
