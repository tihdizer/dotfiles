{ inputs, ... }:
{
  flake-file.inputs = {
    preservation = {
      url = "github:nix-community/preservation";
    };
  };

  flake.modules.nixos.skye-preservation =
    {
      lib,
      options,
      ...
    }:
    {
      imports = lib.optional (inputs ? preservation) inputs.preservation.nixosModules.preservation;

      config = lib.mkIf (options ? preservation) {
        preservation = {
          enable = lib.mkDefault true;
          preserveAt."/persistent" = {
            # Persistent system directories across all dotfiles modules
            directories = [
              "/var/log"
              "/var/lib/nixos"
              "/var/lib/systemd/coredump"
              "/var/lib/bluetooth"
              "/var/lib/sops-nix"
              "/var/lib/libvirt"
              "/var/lib/docker"
              "/var/lib/containers"
              "/var/lib/sunshine"
              "/var/lib/aven"
              "/var/lib/dae"
              "/var/lib/OpenRGB"
              "/etc/NetworkManager/system-connections"
            ];

            # Persistent system files
            files = [
              {
                file = "/etc/machine-id";
                inInitrd = true;
                how = "symlink";
                configureParent = true;
              }
              {
                file = "/etc/ssh/ssh_host_rsa_key";
                how = "symlink";
                configureParent = true;
              }
              {
                file = "/etc/ssh/ssh_host_rsa_key.pub";
                how = "symlink";
                configureParent = true;
              }
              {
                file = "/etc/ssh/ssh_host_ed25519_key";
                how = "symlink";
                configureParent = true;
              }
              {
                file = "/etc/ssh/ssh_host_ed25519_key.pub";
                how = "symlink";
                configureParent = true;
              }
            ];

            # Persistent user directories and state for tihdizer
            users.tihdizer = {
              home = "/home/tihdizer";
              directories = [
                # Development & AI Tooling
                "projects"
                "dotfiles"
                ".jcode"
                ".gemini"
                ".n8n"

                # Core XDG and Application State
                ".config"
                ".local/state"
                ".local/bin"
                ".cache/cliphist"
                ".cache/art-wallpaper"
                ".local/share/keyrings"
                ".local/share/direnv"
                ".local/share/zsh"
                ".local/share/atuin"
                ".local/share/zoxide"
                ".local/share/nix"
                ".local/share/icons"
                ".local/share/fonts"
                ".local/share/applications"
                ".local/share/containers"
                ".local/share/omniroute"
                ".config/cli-proxy-api"
                ".config/oh-my-cpa"
                ".local/share/oh-my-cpa"
                ".local/share/transmission"
                ".local/share/chrome-server"

                # Secrets, SSH & GPG Keys
                ".ssh"
                ".gnupg"
                ".pki"
                ".android"

                # Gaming
                ".steam"

                # Learning
                ".local/share/Anki2"

                # Communication, Browsers & Mail
                ".local/share/TelegramDesktop"
                ".local/share/vesktop"
                ".config/vesktop"
                ".config/Vencord"
                ".mozilla"
                ".zen"
                ".floorp"
                ".thunderbird"
              ];

              files = [
                ".zsh_history"
              ];
            };
          };
        };
      };
    };
}
