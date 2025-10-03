{ inputs, lib, pkgs, ... }:
{
  imports = [
    inputs.zen-browser.homeModules.beta
    ./neovim.nix
    ./zsh.nix
  ];

  nix.package = lib.mkDefault pkgs.nix;
  nix.settings.experimental-features = "nix-command flakes";

  home = {
    username = "ben";
    homeDirectory = "/home/ben";
    stateVersion = "25.05";
    packages = with pkgs; [
      fd
      neovide
      nodejs # Bunch of things may need it
      ripgrep
      tldr
      wl-clipboard # Copy-paste in Wayland
    ];
  };

  programs.btop.enable = true;
  programs.fzf.enable = true;
  programs.gh.enable = true;
  programs.home-manager.enable = true;
  programs.htop.enable = true;
  programs.starship.enable = true;
  programs.zen-browser.enable = true;
  programs.zoxide.enable = true;

  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
    extraOptions = [ "--group-directories-first" ];
  };

  programs.bat = {
    enable = true;
    config.theme = "Visual Studio Dark+";
    extraPackages = with pkgs.bat-extras; [
      batman batdiff batwatch
    ];
  };

  programs.git = {
    enable = true;
    userName = "benvonh";
    userEmail = "benjaminvonsnarski@gmail.com";
    extraConfig.pull.rebase = false;
  };

  programs.ranger = {
    enable = true;
    extraPackages = [
      pkgs.python3Packages.pillow
    ];
    settings = {
      draw_borders = "both";
      preview_images = true;
      preview_images_method = "kitty";
    };
  };

  programs.kitty = {
    enable = true;
    # themeFile = "gruvbox";
    shellIntegration.mode = "no-cursor";
    settings = {
      include = "${../../asset/Catppuccin-Nivem.conf}";
      cursor_trail = 8;
      window_padding_width = 8;
    };
    font = {
      size = 12;
      name = "CaskaydiaCove NF";
      package = pkgs.nerd-fonts.caskaydia-cove;
    };
  };
}
