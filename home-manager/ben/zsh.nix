{ config, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    defaultKeymap = "emacs";
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ga = "git add";
      gd = "git diff";
      gc = "git commit";
      gs = "git status";
      gp = "git pull && git push";
      ngc = "nix-collect-garbage -d";
      hms = "home-manager switch --flake ~/nivem";
      nrs = "sudo nixos-rebuild switch --flake ~/nivem";
      # vim = "nvim";
    };
    initContent = ''
      function nrn {
        if [ $# -eq 0 ]; then
          echo "usage: nrn <package> [<arguments>]"
          return 1
        fi

        local pkg="$1"
        shift

        nix run "nixpkgs#$pkg" -- "$@"
      }
      
      function nbn {
        if [ $# -ne 1 ]; then
          echo "usage: nbn <package>"
          return 1
        fi

        nix build "nixpkgs#$1"
      }

      function ndn {
        if [ $# -ne 1 ]; then
          echo "usage: ndn <package>"
          return 1
        fi

        nix develop "nixpkgs#$1"
      }

      ${pkgs.microfetch}/bin/microfetch
    '';
    plugins = [ {
      name = "notify";
      src = pkgs.fetchFromGitHub {
        owner = "marzocchi";
        repo = "zsh-notify";
        rev = "v1.0";
        sha256 = "sha256-d0MD3D4xiYVhMIjAW4npdtwHSobq6yEqyeSbOPq3aQM";
      };
    } ];
    sessionVariables = {
      OPENER = "bat";
      PAGER = "bat --force-colorization --paging=always --style=full";
    };
    history = {
      ignoreAllDups = true;
      expireDuplicatesFirst = true;
      path = "${config.xdg.cacheHome}/zsh/history";
    };
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    mouse = true;
    baseIndex = 1;
    escapeTime = 300;
    # shortcut = "v";
    terminal = "screen-256color";
    shell = "${pkgs.zsh}/bin/zsh";
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-dir '${config.xdg.cacheHome}/tmux/resurrect'
          set -g @resurrect-save 'G'
          set -g @resurrect-restore 'R'
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = continuum;
        extraConfig = "set -g @continuum-restore 'on'";
      }
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_window_status 'icon'

          set -g @catppuccin_application_color "#{thm_red}"
          set -g @catppuccin_directory_color "#{thm_orange}"
          set -g @catppuccin_host_color "#{thm_yellow}"
          set -g @catppuccin_date_time_color "#{thm_cyan}"

          set -g @catppuccin_date_time_icon ''
          set -g @catppuccin_date_time_text '%H:%M'

          set -g @catppuccin_status_left_separator ' '
          set -g @catppuccin_status_right_separator ''
          set -g @catppuccin_status_connect_separator 'no'
          set -g @catppuccin_status_modules_right 'application directory host session date_time cpu'
        '';
      }
      vim-tmux-navigator
      fuzzback
      extrakto
      copycat
      yank
      cpu
    ];

    # TODO: cheat sheet
    extraConfig = ''
      set -g status-position top
      set-option -sa terminal-overrides ',xterm-256color:RGB'
      bind | split-window -h
      bind - split-window -v
      bind h popup -w 20 -h 4 '${pkgs.cheat}/bin/cheat'
    '';
    };
  }
