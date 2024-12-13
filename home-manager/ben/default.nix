{ inputs, outputs, lib, config, pkgs, ... }:
{
  imports = [
    ./zsh.nix
    ./neovim.nix
    ./hyprland.nix
  ];

  ##################################################
  #                 BASIC SETTINGS                 #
  ##################################################
  nix = {
    package = pkgs.nix;
    settings.experimental-features = "nix-command flakes";
  };

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config.allowUnfree = true;
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "Ubuntu Sans" ];
      sansSerif = [ "Ubuntu Sans" ];
      monospace = [ "CaskaydiaCove NF" ];
    };
  };

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
    ];
  };

  programs.home-manager.enable = true;
  programs.ranger.enable = true;
  programs.htop.enable = true;
  programs.gh.enable = true;
  programs.git = {
    enable = true;
    userName = "benvonh";
    userEmail = "benjaminvonsnarski@gmail.com";
  };


  programs.kitty = {
    enable = true;
    themeFile = "Catppuccin-Mocha";
    shellIntegration.mode = "no-cursor";
    settings.window_padding_width = 4;
    font = {
      size = 12;
      name = "CaskaydiaCove NF";
      package = (pkgs.nerdfonts.override {
        fonts = [ "CascadiaCode" ];
      });
    };
  };

  programs.rofi = {
    enable = true;
    cycle = false;
    terminal = "kitty";
    package = pkgs.rofi-wayland;
    font = "CaskaydiaCove NF";
    theme = ./rofi.rasi;
  };

  systemd.user.startServices = "sd-switch";
}
