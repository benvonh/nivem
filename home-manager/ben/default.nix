{ lib, pkgs, ... }:
{
  imports = [ ./zsh.nix ./neovim.nix ];

  nix.package = lib.mkDefault pkgs.nix;
  nix.settings.experimental-features = "nix-command flakes";

  # TODO: Maybe only needed in NixOS config?
  # fonts.fontconfig = {
  #   enable = true;
  #   defaultFonts = {
  #     serif = [ "Ubuntu Sans" ];
  #     sansSerif = [ "Ubuntu Sans" ];
  #     monospace = [ "CaskaydiaCove NF" ];
  #   };
  # };

  #################################################
  #                 USER SETTINGS                 #
  #################################################
  home = {
    username = "ben";
    homeDirectory = "/home/ben";
    stateVersion = "24.11";
    packages = with pkgs; [
      wl-clipboard # Copy-paste in Wayland
      nodejs # Bunch of things may need it
      tldr
      neovide
    ];
  };

  programs.rofi = {
    enable = true;
    cycle = false;
    terminal = "kitty";
    package = pkgs.rofi-wayland;
    font = "CaskaydiaCove NF";
    theme = ./rofi.rasi;
  };

  programs.home-manager = {
    enable = true;
  };

  programs.htop.enable = true;
  programs.gh.enable = true;

  programs.git = {
    enable = true;
    userName = "benvonh";
    userEmail = "benjaminvonsnarski@gmail.com";
    extraConfig.pull.rebase = false;
  };

  programs.kitty = {
    enable = true;
    themeFile = "gruvbox-dark";
    shellIntegration.mode = "no-cursor";
    settings = {
      cursor_trail = 10;
      window_padding_width = 8;
    };
    font = {
      size = 11;
      name = "CaskaydiaCove NF";
      # name = "Departure Mono";
      # package = pkgs.departure-mono;
    };
  };
}
