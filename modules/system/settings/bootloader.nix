{ ... }:
{
  flake.modules.nixos.system-bootloader =
    { ... }:
    {
      # Boot
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.timeout = 0;
      boot.consoleLogLevel = 3;
      boot.kernelParams = [
        "quiet"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
      ];
    };
}
