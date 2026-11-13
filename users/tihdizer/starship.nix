{ ... }:
let
  settings = {
    add_newline = false;
    command_timeout = 1300;
    scan_timeout = 50;
    jobs.disabled = true;
    shell.disabled = true;

    format = ''
      [╭──╼](bold blue) $username [at](bright-black) $hostname [on](bright-black) $os
      [│](bold blue) $directory$git_branch$git_commit$git_state$git_metrics$git_status$kubernetes$rust
      [╰─](bold blue)$character'';
    right_format = ''($cmd_duration )($status )at $time'';

    character = {
      success_symbol = "[>](bold yellow)";
      error_symbol = "[>](bold red)";
      vimcmd_symbol = "[<](bold yellow)";
      vimcmd_visual_symbol = "[v](bold yellow)";
    };

    directory = {
      read_only = " ";
      format = "[$path]($style)[$read_only]($read_only_style) ";
      style = "bold cyan";
    };

    cmd_duration = {
      min_time = 2000;
      format = "took [$duration]($style)";
      style = "bold yellow";
    };

    git_branch = {
      format = "[$branch]($style) ";
      style = "bright-black";
    };

    git_status = {
      format = "$ahead_behind$all_status";
      ahead = "[↑\${count}](green) ";
      behind = "[↓\${count}](red) ";
      diverged = "[↑\${ahead_count}](green)[↓\${behind_count}](red) ";
      modified = "[~\${count}](yellow) ";
      staged = "[+\${count}](green) ";
      untracked = "[?\${count}](blue) ";
      deleted = "[-\${count}](red) ";
      conflicted = "[=\${count}](red) ";
      stashed = "[*\${count}](bright-black) ";
    };

    rust = {
      format = "via [rust]($style) ";
      style = "bold red";
    };

    status = {
      disabled = false;
      format = "[$symbol$status]($style)";
      symbol = " ";
      style = "bold red";
    };

    time = {
      disabled = false;
      format = "[$time]($style)";
      style = "bright-black";
      time_format = "%R";
    };

    username = {
      show_always = true;
      format = "[$user]($style)";
      style_user = "bold green";
      style_root = "bold red";
    };

    hostname = {
      ssh_only = false;
      format = "[$hostname]($style)";
      style = "bold blue";
    };

    os = {
      disabled = false;
      format = "[$symbol$name v$version]($style)";
      style = "bold cyan";
      symbols = {
        NixOS = " ";
      };
    };
  };
in
{
  flake.modules.nixos.starship =
    { ... }:
    {
      programs.starship = {
        enable = true;
        settings = settings;
      };
    };

  flake.modules.nixos.tihdizer-starship =
    { ... }:
    {
      programs.starship = {
        enable = true;
        settings = settings;
      };
    };

  flake.modules.homeManager.tihdizer-starship =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.fish.enable = lib.mkDefault true;
      programs.zsh = {
        enable = lib.mkDefault true;
        initContent = ''
          export KEYTIMEOUT=1
          ZLE_RPROMPT_INDENT=0
        '';
      };
      home.packages = with pkgs; [ starship ];

      programs.starship = {
        enable = true;
        package = pkgs.starship;
        enableZshIntegration = config.programs.zsh.enable;
        enableFishIntegration = config.programs.fish.enable;
        enableNushellIntegration = config.programs.fish.enable;
        settings = settings;
      };
    };
}
