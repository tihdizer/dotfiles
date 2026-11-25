{ ... }:
let
  extensionIds = [
    "cfhdojbkjhnklbpkdaibdccddilifddb" # Adblock Plus
    "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
    "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
    "hkgfoiooedgoejojocmhlaklaeopbecg" # Picture-in-Picture Extension (by Google)
    "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock for YouTube
    "gibipneadnbflmkebnmcbgjdkngkbklb" # Windowed
    "onljnjnbfggbdnobigopggefjpkoojjj" # Oxford Learner's Dictionary
  ];
in
{
  flake.modules.homeManager.chrome =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        google-chrome
      ];

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
}
