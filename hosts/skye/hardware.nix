{ ... }:
{
  flake.modules.nixos.skye-hardware =
    { config, lib, modulesPath, ... }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];

      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ ];
      boot.supportedFilesystems = [ "btrfs" ];
      boot.extraModulePackages = [ ];

      networking.useDHCP = lib.mkDefault false;
      networking.interfaces.enp42s0.wakeOnLan.enable = true;

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
