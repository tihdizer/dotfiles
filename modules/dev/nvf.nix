{ inputs, ... }:
let
  sharedPackages =
    pkgs: with pkgs; [
      fzf
      ripgrep
      fd
      lazygit
    ];

  sharedNvf = pkgs: {
    enable = true;

    settings.vim = {
      viAlias = true;
      vimAlias = true;
      preventJunkFiles = true;

      clipboard = {
        enable = true;
        registers = "unnamedplus";
        providers = {
          wl-copy.enable = true;
        };
      };

      options = {
        number = true;
        relativenumber = true;

        tabstop = 2;
        shiftwidth = 2;
        softtabstop = 2;
        expandtab = true;

        smartindent = true;
        scrolloff = 5;

        ignorecase = true;
        smartcase = true;

        splitbelow = true;
        splitright = true;

        updatetime = 250;
        timeoutlen = 400;
        termguicolors = true;
      };

      lsp = {
        enable = true;
        formatOnSave = false;

        trouble.enable = true;
        lightbulb.enable = true;
      };

      autocomplete.blink-cmp.enable = true;

      languages = {
        enableTreesitter = true;

        nix = {
          enable = true;
          format.enable = true;

          lsp = {
            enable = true;
            servers = [ "nixd" ];
          };
        };

        bash = {
          enable = true;
          format.enable = true;
        };

        rust = {
          enable = true;
          format.enable = true;
        };

        python = {
          enable = true;
          format.enable = true;
        };

        terraform = {
          enable = true;
          format.enable = true;
        };

        yaml = {
          enable = true;
          format.enable = true;
        };

        docker = {
          enable = true;
          format.enable = true;
        };

        json.enable = true;
        toml.enable = true;
        sql.enable = true;
        markdown.enable = true;
        typst.enable = true;
      };

      spellcheck.enable = true;

      git = {
        enable = true;
        gitsigns.enable = true;
      };

      debugger.nvim-dap = {
        enable = true;
        ui.enable = true;
      };

      autopairs.nvim-autopairs.enable = true;

      comments.comment-nvim.enable = true;

      utility = {
        surround.enable = true;
        undotree.enable = true;
        grug-far-nvim.enable = true;

        motion.leap.enable = true;
      };

      utility.yazi-nvim.enable = true;

      statusline.lualine.enable = true;

      binds.whichKey.enable = true;

      notify.nvim-notify.enable = true;

      notes.todo-comments.enable = true;

      ui = {
        borders.enable = true;
        colorizer.enable = true;
        illuminate.enable = true;

        smartcolumn = {
          enable = true;

          setupOpts.custom_colorcolumn = {
            nix = "110";
            rust = "100";
            python = "88";
          };
        };

        fastaction.enable = true;
      };

      fzf-lua = {
        enable = true;
        profile = "telescope";
      };

      extraPlugins.zellij-nav-nvim = {
        package = pkgs.vimPlugins.zellij-nav-nvim;
        setup = ''
          require("zellij-nav").setup({})

          vim.keymap.set("n", "<C-h>", "<cmd>ZellijNavigateLeft<cr>", { silent = true, desc = "Navigate left" })
          vim.keymap.set("n", "<C-j>", "<cmd>ZellijNavigateDown<cr>", { silent = true, desc = "Navigate down" })
          vim.keymap.set("n", "<C-k>", "<cmd>ZellijNavigateUp<cr>", { silent = true, desc = "Navigate up" })
          vim.keymap.set("n", "<C-l>", "<cmd>ZellijNavigateRight<cr>", { silent = true, desc = "Navigate right" })
        '';
      };

      keymaps = [
        {
          key = "<leader>y";
          mode = "n";
          action = "<cmd>Yazi<cr>";
          desc = "Yazi";
        }

        {
          key = "<leader><space>";
          mode = "n";
          action = "<cmd>FzfLua files<cr>";
          desc = "Find files";
        }

        {
          key = "<leader>sf";
          mode = "n";
          action = "<cmd>FzfLua files<cr>";
          desc = "Search files";
        }

        {
          key = "<leader>/";
          mode = "n";
          action = "<cmd>FzfLua live_grep<cr>";
          desc = "Grep text";
        }

        {
          key = "<leader>sg";
          mode = "n";
          action = "<cmd>FzfLua live_grep<cr>";
          desc = "Search grep";
        }

        {
          key = "<leader>gl";
          mode = "n";
          action = "<cmd>LazyGit<cr>";
          desc = "LazyGit";
        }

        {
          key = "<leader>fm";
          mode = "n";
          action = "<cmd>lua vim.lsp.buf.format()<cr>";
          desc = "Format buffer";
        }

        {
          key = "<leader>xx";
          mode = "n";
          action = "<cmd>Trouble diagnostics toggle<cr>";
          desc = "Diagnostics";
        }

        {
          key = "<leader>dd";
          mode = "n";
          action = "<cmd>lua require('dap').continue()<cr>";
          desc = "Debug continue";
        }

        {
          key = "<leader>db";
          mode = "n";
          action = "<cmd>lua require('dap').toggle_breakpoint()<cr>";
          desc = "Debug breakpoint";
        }

        {
          key = "<leader>df";
          mode = "n";
          action = "<cmd>lua require('dap').repl.open()<cr>";
          desc = "Debug REPL";
        }
      ];
    };
  };
in
{
  flake-file.inputs = {
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.nvf =
    { pkgs, ... }:
    {
      imports = [
        inputs.nvf.nixosModules.default
      ];

      environment.systemPackages = sharedPackages pkgs;

      environment.sessionVariables = {
        EDITOR = "vim";
        VISUAL = "vim";
      };

      programs.nvf = sharedNvf pkgs;
    };

  flake.modules.homeManager.nvf =
    { pkgs, ... }:
    {
      imports = [
        inputs.nvf.homeManagerModules.default
      ];

      home.packages = sharedPackages pkgs;

      home.sessionVariables = {
        EDITOR = "vim";
        VISUAL = "vim";
      };

      programs.nvf = sharedNvf pkgs;
    };
}
