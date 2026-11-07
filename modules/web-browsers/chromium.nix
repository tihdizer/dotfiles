{ ... }:
let
  extensionIds = [
    "cfhdojbkjhnklbpkdaibdccddilifddb" # Adblock Plus
    "dnhpnfgdlenaccegplpojghhmaamnnfp" # Augmented Steam
    "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
    "gmhgdiamihghcepkeapfoeakphffcdkk" # Merriam-Webster Dictionary
    # "onljnjnbfggbdnobigopggefjpkoojjj" # Oxford Learner's Dictionary Lookup
    "akimgimeeoiognljlfchpbkpfbmeapkh" # Google Arts & Culture
    "ghbmnnjooekpmoecnnnilnnbdlolhkhi" # Google Docs Offline
    "aapbdbdomjkkjkaonfhkkikfgjllcleb" # Google Translate
    "hkgfoiooedgoejojocmhlaklaeopbecg" # Picture-in-Picture Extension (by Google)
    "mmioliijnhnoblpgimnlajmefafdfilb" # Shazam
    "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock for YouTube
    "kdbmhfkmnlmbkgbabkdealhhbfhlmmon" # SteamDB
    "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
    # "hfjbmagddngcpeloejdejnfgbamkjaeg" # Vimium C
    "ijgkbcbalaekboipcmaefchfjpognmog" # VK Music Saver
    "gibipneadnbflmkebnmcbgjdkngkbklb" # Windowed
  ];
in
{
  flake.modules.homeManager.chromium =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        google-chrome
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

      home.file = builtins.listToAttrs (
        map (id: {
          name = ".config/google-chrome/External Extensions/${id}.json";
          value = {
            text = builtins.toJSON {
              external_update_url = "https://clients2.google.com/service/update2/crx";
            };
          };
        }) extensionIds
      );
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
