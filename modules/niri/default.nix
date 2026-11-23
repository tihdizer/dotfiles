{ inputs, ... }:
{
  flake.modules.nixos.niri = {
    imports = with inputs.self.modules.nixos; [
      niri-dbus
      niri-session-manager
      niri-env
      niri-autoselect-portal
    ];

    security.pam.services.swaylock.enableGnomeKeyring = true;
  };
}
