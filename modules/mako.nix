{ ... }:
{
  flake-file.inputs = { };

  flake.modules.nixos.mako =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        mako
        libnotify
      ];
    };

  flake.modules.homeManager.mako =
    {
      config,
      options,
      lib,
      pkgs,
      ...
    }:
    let
      rawColors =
        if config ? lib.stylix then
          config.lib.stylix.colors.withHashtag
        else
          {
            base00 = "#272e33";
            base01 = "#2e383c";
            base02 = "#414b50";
            base03 = "#859289";
            base04 = "#9da9a0";
            base05 = "#d3c6aa";
            base06 = "#edeada";
            base07 = "#fffbef";
            base08 = "#e67e80";
            base09 = "#e69875";
            base0A = "#dbbc7f";
            base0B = "#a7c080";
            base0C = "#83c092";
            base0D = "#7fbbb3";
            base0E = "#d699b6";
            base0F = "#9da9a0";
          };

      font =
        if config ? stylix.fonts then
          "${config.stylix.fonts.sansSerif.name} ${toString (config.stylix.fonts.sizes.popups or 12)}"
        else
          "DejaVu Sans 12";

      opacityHex =
        if (config ? stylix.opacity.popups && config.stylix.opacity.popups != 1.0) then
          let
            hex = lib.toLower (lib.toHexString (builtins.ceil (config.stylix.opacity.popups * 255)));
          in
          if builtins.stringLength hex == 1 then "0${hex}" else hex
        else
          "f2";
    in
    {
      stylix = lib.mkIf (options ? stylix) {
        targets.mako.enable = false;
      };

      home.packages = [ pkgs.libnotify ];

      services.mako = {
        enable = true;
        settings = {
          # Position matched from steam in window-rules.nix
          anchor = "bottom-right";
          margin = "1";
          output = "DP-4";

          # Geometry & layout
          width = 360;
          height = 110;
          border-size = 2;
          border-radius = 12;
          padding = "12,16";
          layer = "overlay";

          # Typography & colors (stylix integration)
          font = font;
          background-color = "${rawColors.base00}${opacityHex}";
          text-color = "${rawColors.base05}ff";
          border-color = "${rawColors.base0D}ff";
          progress-color = "over ${rawColors.base02}ff";

          # Behavior
          default-timeout = 5000;
          ignore-timeout = false;
          max-visible = 5;
          sort = "+time";
          icons = true;
          max-icon-size = 48;
          max-history = 50;
          actions = true;

          # Urgency configurations
          "urgency=low" = {
            background-color = "${rawColors.base00}${opacityHex}";
            border-color = "${rawColors.base03}ff";
            text-color = "${rawColors.base05}ff";
            default-timeout = 3000;
          };

          "urgency=normal" = {
            background-color = "${rawColors.base00}${opacityHex}";
            border-color = "${rawColors.base0D}ff";
            text-color = "${rawColors.base05}ff";
            default-timeout = 5000;
          };

          "urgency=critical" = {
            background-color = "${rawColors.base00}${opacityHex}";
            border-color = "${rawColors.base08}ff";
            text-color = "${rawColors.base05}ff";
            default-timeout = 0;
          };
        };
      };
    };
}
