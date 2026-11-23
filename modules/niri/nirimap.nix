{ inputs, ... }:
let
  build = pkgs: pkgs.rustPlatform.buildRustPackage {
    pname = "nirimap";
    version = "unstable";
    src = inputs.nirimap;

    nativeBuildInputs = [ pkgs.pkg-config pkgs.wrapGAppsHook4 ];
    buildInputs = [ pkgs.gtk4 pkgs.gtk4-layer-shell pkgs.libxkbcommon ];

    cargoHash = "sha256-Ya9P2nP0Z2LX0Rmun/J3llh+Q4EBE0pM88rCVtYBT4w=";
  };

  defaultColors = {
    base00 = "1e1e2e"; # background
    base01 = "1e1e2e"; # background alternative
    base02 = "45475a"; # window_color
    base03 = "6c7086"; # border_color
    base05 = "cdd6f4"; # text color
    base0D = "89b4fa"; # focused_color
  };

  defaultFonts = {
    sansSerif.name = "Sans";
    sizes.desktop = 10;
  };

  makeConfig = cfg: let
    hasStylix = cfg.stylix.enable or false;
    scheme = if hasStylix then cfg.lib.stylix.colors else defaultColors;
    fonts = if hasStylix then cfg.stylix.fonts else defaultFonts;
  in ''
    [display]
    height = 100                                                 # Per-workspace row height in pixels
    max_width_percent = 0.5                                      # Maximum width as fraction of screen (0.0 - 1.0)
    max_height_percent = 0.5                                     # Maximum height as fraction of screen ("all" mode)
    anchor = "bottom-right"                                      # Position: top-left, top-center, top-right, bottom-left, etc.
    margin_x = 10                                                # Horizontal margin from edge
    margin_y = 42                                                # Vertical margin from edge
    workspace_mode = "current"                                   # "all" - stack every workspace, "current" - show active only

    [appearance]
    background = "#${scheme.base01}"                             # Background color (hex)
    window_color = "#${scheme.base02}"                           # Default window rectangle color
    focused_color = "#${scheme.base0D}"                          # Focused window highlight
    border_color = "#${scheme.base03}"                           # Window border color
    border_width = 1                                             # Window border thickness
    border_radius = 2                                            # Corner radius for window rectangles
    gap = 2                                                      # Gap between windows (in minimap pixels)
    background_opacity = 0.0                                     # Background opacity (0.0 = transparent, 1.0 = opaque)
    window_opacity = 0.5                                         # Fill opacity for unfocused windows (0 = outlines only)
    focused_opacity = 0.6                                        # Fill opacity for the focused window
    workspace_gap = 4                                            # Vertical gap between stacked workspaces ("all" mode)
    active_workspace_border_color = "#${scheme.base0D}"          # Highlight border for active workspace
    active_workspace_border_width = 2                            # Highlight border thickness ("all" mode)

    [labels]
    enabled = false                                              # Draw text labels on window rectangles
    content = "title"                                            # What to show: "title", "app-id", "app-id-title", "none"
    font_family = "${fonts.sansSerif.name}"                      # Font family name
    font_size = ${toString fonts.sizes.desktop}                  # Font size in pixels
    font_weight = "normal"                                       # "normal" or "bold"
    font_style = "normal"                                        # "normal" or "italic"
    color = "#${scheme.base05}"                                  # Text color
    focused_color = "#${scheme.base00}"                          # Text color on the focused window
    position = "center"                                          # Anchor within the window rectangle
    padding = 2                                                  # Inner padding between label and window edge
    min_window_size = 30                                         # Skip labels on rectangles smaller than this
    shadow = false                                               # Dark drop shadow behind text for legibility

    [icons]
    enabled = true                                               # Draw application icons on window rectangles
    size = "auto"                                                # "auto" (scales with the rectangle) or explicit pixels
    position = "center"                                          # Anchor within the window rectangle
    opacity = 0.7                                                # Icon opacity (0.0 - 1.0)
    min_window_size = 16                                         # Skip icons on rectangles smaller than this

    [behavior]
    show_on_overview = true                                      # Keep visible in Niri overview mode
    always_visible = false                                       # Always show minimap (false = only on events)
    hide_timeout_ms = 1000                                       # Milliseconds before hiding after an event
    show_for_floating_windows = true                             # Surface the minimap for floating-window events
  '';
in
{
  flake-file.inputs = {
    nirimap = {
      url = "github:alexandergknoll/nirimap/develop";
      flake = false;
    };
  };

  flake.modules.nixos.nirimap =
    { config, pkgs, ... }:
    {
      environment.systemPackages = [ (build pkgs) ];
      environment.etc."xdg/nirimap/config.toml".text = makeConfig config;
    };

  flake.modules.homeManager.nirimap =
    { config, pkgs, ... }:
    {
      home.packages = [ (build pkgs) ];
      xdg.configFile."nirimap/config.toml".text = makeConfig config;
      programs.niri.settings.spawn-at-startup = [
        { sh = "nirimap"; }
      ];
    };
}
