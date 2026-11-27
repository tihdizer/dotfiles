{ inputs, ... }:
let
  extensionRegistry = {
    adblockPlus = "cfhdojbkjhnklbpkdaibdccddilifddb";
    augmentedSteam = "dnhpnfgdlenaccegplpojghhmaamnnfp";
    darkReader = "eimadpbcbfnmbkopoojfekhnkhdbieeh";
    oxfordLearners = "onljnjnbfggbdnobigopggefjpkoojjj";
    googleArts = "akimgimeeoiognljlfchpbkpfbmeapkh";
    googleDocsOffline = "ghbmnnjooekpmoecnnnilnnbdlolhkhi";
    pip = "hkgfoiooedgoejojocmhlaklaeopbecg";
    shazam = "mmioliijnhnoblpgimnlajmefafdfilb";
    sponsorBlock = "mnjggcdmjocbbbhaepdhchncahnbgone";
    steamDb = "kdbmhfkmnlmbkgbabkdealhhbfhlmmon";
    vimium = "dbepggeogbaibhgnhhndojpepiihcmeb";
    vkMusicSaver = "ijgkbcbalaekboipcmaefchfjpognmog";
    windowed = "gibipneadnbflmkebnmcbgjdkngkbklb";
  };

  commonExtensions = with extensionRegistry; [
    adblockPlus
    darkReader
    vimium
    pip
    windowed
    googleArts
    oxfordLearners
    sponsorBlock
  ];

  workspaceExtensions = with extensionRegistry; {
    personal = [
      shazam
    ];
    study = [ ];
    work = [ ];
    games = [
      augmentedSteam
      steamDb
    ];
    media = [
      shazam
      vkMusicSaver
    ];
    comms = [
    ];
    ops = [ ];
    stash = [ ];
  };
in
{
  flake.modules.homeManager.tihdizer-niri-workspaces-chromium =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib) getExe;
      niri =
        if config.programs ? niri.package then
          getExe config.programs.niri.package
        else
          "${pkgs.niri}/bin/niri";
      jq = getExe pkgs.jq;
      sed = getExe pkgs.gnused;
      chromiumBin = "${pkgs.chromium}/bin/chromium";

      chromiumWorkspaceLauncher = pkgs.writeShellScriptBin "chromium-workspace" ''
        set -euo pipefail

        WS_NAME=""
        if [ -n "''${NIRI_SOCKET:-}" ] || command -v ${niri} >/dev/null 2>&1; then
          WS_NAME="$(${niri} msg -j workspaces 2>/dev/null | ${jq} -r 'first(.[] | select(.is_focused == true) | .name) // empty' 2>/dev/null || true)"
        fi

        SAFE_WS="$(echo "''${WS_NAME:-}" | ${sed} 's/[^a-zA-Z0-9_-]/_/g')"
        case "$SAFE_WS" in
          personal|comms|study|work|games|ops|media|stash)
            ;;
          *)
            SAFE_WS="personal"
            ;;
        esac

        BASE_DIR="$HOME/.config/chromium-workspaces"
        DATA_DIR="$BASE_DIR/$SAFE_WS"
        mkdir -p "$DATA_DIR/Default" 2>/dev/null || {
          SAFE_WS="personal"
          DATA_DIR="$BASE_DIR/personal"
          mkdir -p "$DATA_DIR/Default"
        }

        if [ ! -d "$DATA_DIR/External Extensions" ] && [ -d "$BASE_DIR/default/External Extensions" ]; then
          mkdir -p "$DATA_DIR/External Extensions"
          cp -rn "$BASE_DIR/default/External Extensions/"* "$DATA_DIR/External Extensions/" 2>/dev/null || true
        fi

        PROFILE_NAME="$(echo "''${SAFE_WS:0:1}" | tr '[:lower:]' '[:upper:]')''${SAFE_WS:1}"

        PREFS="$DATA_DIR/Default/Preferences"
        if [ ! -f "$PREFS" ]; then
          echo "{\"session\":{\"restore_on_startup\":1},\"profile\":{\"name\":\"$PROFILE_NAME\"},\"intl\":{\"selected_languages\":\"en-GB-oxendict,en-GB,en\",\"accept_languages\":\"en-GB-oxendict,en-GB,en\"},\"spellcheck\":{\"dictionaries\":[\"en-GB-oxendict\"]}}" > "$PREFS"
        else
          PREF_CONTENT="$(${jq} --arg name "$PROFILE_NAME" '
            .profile.name = $name |
            .intl.selected_languages = "en-GB-oxendict,en-GB,en" |
            .intl.accept_languages = "en-GB-oxendict,en-GB,en" |
            .spellcheck.dictionaries = ["en-GB-oxendict"]
          ' "$PREFS" 2>/dev/null || true)"
          if [ -n "$PREF_CONTENT" ]; then
            printf '%s\n' "$PREF_CONTENT" > "$PREFS"
          fi
        fi

        LOCAL_STATE="$DATA_DIR/Local State"
        if [ -f "$LOCAL_STATE" ]; then
          LS_CONTENT="$(${jq} --arg name "$PROFILE_NAME" '
            if .profile.info_cache.Default then
              .profile.info_cache.Default.name = $name |
              .profile.info_cache.Default.is_using_default_name = false
            else . end
          ' "$LOCAL_STATE" 2>/dev/null || true)"
          if [ -n "$LS_CONTENT" ]; then
            printf '%s\n' "$LS_CONTENT" > "$LOCAL_STATE"
          fi
        fi

        HAS_USER_DATA_DIR=0
        for arg in "$@"; do
          case "$arg" in
            --user-data-dir|--user-data-dir=*) HAS_USER_DATA_DIR=1 ;;
          esac
        done

        if [ "$HAS_USER_DATA_DIR" -eq 1 ]; then
          exec ${chromiumBin} "$@"
        else
          exec ${chromiumBin} --user-data-dir="$DATA_DIR" "$@"
        fi
      '';

      chromiumWrapper = pkgs.writeShellScriptBin "chromium" ''
        exec ${chromiumWorkspaceLauncher}/bin/chromium-workspace "$@"
      '';

      chromiumBrowserWrapper = pkgs.writeShellScriptBin "chromium-browser" ''
        exec ${chromiumWorkspaceLauncher}/bin/chromium-workspace "$@"
      '';
    in
    {
      home.packages = [
        chromiumWorkspaceLauncher
        (lib.hiPrio chromiumWrapper)
        (lib.hiPrio chromiumBrowserWrapper)
      ];

      xdg.desktopEntries = {
        chromium-browser = {
          name = "Chromium";
          genericName = "Web Browser";
          comment = "Access the Internet with workspace-specific profile";
          exec = "${chromiumWorkspaceLauncher}/bin/chromium-workspace %U";
          icon = "chromium";
          terminal = false;
          categories = [
            "Network"
            "WebBrowser"
          ];
          mimeType = [
            "text/html"
            "text/xml"
            "application/xhtml+xml"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
            "x-scheme-handler/about"
            "x-scheme-handler/unknown"
            "x-scheme-handler/mailto"
          ];
          actions = {
            "new-window" = {
              name = "New Window";
              exec = "${chromiumWorkspaceLauncher}/bin/chromium-workspace";
            };
            "new-private-window" = {
              name = "New Incognito Window";
              exec = "${chromiumWorkspaceLauncher}/bin/chromium-workspace --incognito";
            };
          };
        };
      };

      home.file = builtins.listToAttrs (
        lib.flatten (
          lib.mapAttrsToList (
            ws: exts:
            let
              allExts = lib.unique (commonExtensions ++ exts);
            in
            map (id: {
              name = ".config/chromium-workspaces/${ws}/External Extensions/${id}.json";
              value = {
                text = builtins.toJSON {
                  external_update_url = "https://clients2.google.com/service/update2/crx";
                };
              };
            }) allExts
          ) workspaceExtensions
        )
      );
    };
}
