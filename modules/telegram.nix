{ ... }:
let
  tele =
    pkgs:
    pkgs.buildGoModule rec {
      pname = "tele";
      version = "2.0.2";

      src = pkgs.fetchFromGitHub {
        owner = "sorokin-vladimir";
        repo = "tele";
        rev = "v${version}";
        hash = "sha256-+/1gC1oGBQnYXfnB1AI/C0jScO36RCtGi9VnE+cb6bI=";
      };

      vendorHash = "sha256-eCWK0KmDdsZWMx4RIXyJ8chbG6wGfXTuS0jTF4eB02M=";

      subPackages = [ "cmd/tele" ];

      env.CGO_ENABLED = "0";

      ldflags = [
        "-s"
        "-w"
        "-X github.com/sorokin-vladimir/tele/internal/version.Version=${version}"
      ];

      doCheck = false;

      meta = with pkgs.lib; {
        description = "A terminal-native Telegram client built for keyboard-driven workflows";
        homepage = "https://github.com/sorokin-vladimir/tele";
        license = licenses.gpl3Only;
        mainProgram = "tele";
        platforms = platforms.unix;
      };
    };

  telegramWeb =
    pkgs:
    let
      app = pkgs.writeShellScriptBin "telegram-web" ''
        exec ${pkgs.chromium}/bin/chromium --app=https://web.telegram.org "$@"
      '';
      desktopItem = pkgs.makeDesktopItem {
        name = "telegram-web";
        desktopName = "Telegram Web";
        genericName = "Telegram Web Client";
        exec = "telegram-web %U";
        icon = "telegram";
        terminal = false;
        categories = [
          "Network"
          "InstantMessaging"
          "Chat"
        ];
        startupWMClass = "chrome-web.telegram.org__-Default";
      };
    in
    pkgs.symlinkJoin {
      name = "telegram-web";
      paths = [
        app
        desktopItem
      ];
    };
in
{
  flake.modules.homeManager.telegram =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.telegram-desktop
        (tele pkgs)
        (telegramWeb pkgs)
      ];
    };
}
