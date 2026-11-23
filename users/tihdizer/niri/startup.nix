{ ... }:
{
  flake.modules.homeManager.tihdizer-niri-startup =
    { pkgs, ... }:
    {
      programs.niri.settings.spawn-at-startup = [
        { sh = "systemctl --user reset-failed"; }
        { command = [ "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1" ]; }
        { sh = "xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2"; }
        { sh = "sway-audio-idle-inhibit"; }
        { sh = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch cliphist store"; }
        { sh = "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch cliphist store"; }
        # { sh = "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all"; }
        { sh = "uwsm finalize"; }
        { sh = "daily-art-wallpaper"; }
        { command = [ "${pkgs.swaylock-effects}/bin/swaylock" "-f" ]; }
        { command = [ "${pkgs.google-chrome}/bin/google-chrome" ]; }
        { command = [ "${pkgs.telegram-desktop}/bin/Telegram" ]; }
      ];
    };
}
