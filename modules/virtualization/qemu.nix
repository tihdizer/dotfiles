{ ... }:
{
  flake.modules.nixos.qemu =
    { pkgs, lib, ... }:
    {
      boot.binfmt.emulatedSystems = [
        "aarch64-linux"
        "riscv64-linux"
      ];

      programs.virt-manager.enable = true;
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
          vhostUserPackages = [ pkgs.virtiofsd ];
        };
      };
      # Socket activation on demand
      systemd.services.libvirtd.wantedBy = lib.mkForce [ ];

      security.wrappers.spice-client-glib-usb-acl-helper = {
        source = "${pkgs.spice-gtk}/bin/spice-client-glib-usb-acl-helper";
        owner = "root";
        group = "root";
        setuid = true;
      };

      environment.sessionVariables = {
        LIBVIRT_DEFAULT_URI = "qemu:///system";
      };

      environment.systemPackages = with pkgs; [
        spice-gtk # Spice VM client
        virtiofsd
        (adwaita-icon-theme.overrideAttrs (_: {
          postPatch = ''
            substituteInPlace index.theme \
              --replace-fail "Hidden=true" ""
          '';
        }))
        adwaita-icon-theme-legacy
      ];
    };
}
