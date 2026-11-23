{ ... }:
{
  flake.modules.nixos.niri-session-manager =
    { pkgs, lib, ... }:
    let
      niri-session = "${pkgs.niri}/bin/niri-session";
    in
    {
      #|==< GNOME Keyring System Daemon >==|#
      services.gnome.gnome-keyring.enable = true;

      #|==< UWSM >==|#
      programs.uwsm = {
        enable = true;
        waylandCompositors.niri = {
          prettyName = "Niri";
          comment = "Scrollable-tiling Wayland compositor";
          binPath = niri-session;
        };
      };
      #|==< Greetd Auto-Login >==|#
      security.pam.services.greetd.enableGnomeKeyring = true;
      services.greetd = {
        enable = true;
        settings = {
          terminal.vt = lib.mkForce 7;
          default_session = {
            command = "${pkgs.uwsm}/bin/uwsm start -g -1 niri-session";
            user = "tihdizer";
          };
        };
      };

      systemd.services.greetd.serviceConfig.Type = lib.mkForce "simple";
    };
}
