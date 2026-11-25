{ ... }:
let
  extensionIds = [
    "cfhdojbkjhnklbpkdaibdccddilifddb" # Adblock Plus
    "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
    "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
    "akimgimeeoiognljlfchpbkpfbmeapkh" # Google Arts & Culture
    "hkgfoiooedgoejojocmhlaklaeopbecg" # Picture-in-Picture Extension (by Google)
    "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock for YouTube
    "gibipneadnbflmkebnmcbgjdkngkbklb" # Windowed
    "onljnjnbfggbdnobigopggefjpkoojjj" # Oxford Learner's Dictionary
  ];
in
{
  flake.modules.homeManager.chromium =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        zenity
      ];

      programs.chromium = {
        enable = true;
        package = pkgs.chromium;
        commandLineArgs = [
          "--enable-app-mode-extensions"
          "--disable-quic"
        ];
        extensions = map (id: { inherit id; }) extensionIds;
      };
    };

  flake.modules.nixos.chromium = {
    programs.chromium = {
      enable = true;
      extraOpts = {
        "ExtensionInstallForcelist" = map (
          id: "${id};https://clients2.google.com/service/update2/crx"
        ) extensionIds;
        "ExtensionSettings" = builtins.listToAttrs (
          map (id: {
            name = id;
            value = {
              "installation_mode" = "force_installed";
              "update_url" = "https://clients2.google.com/service/update2/crx";
            };
          }) extensionIds
        );
      };
    };
  };
}
