{ inputs, outputs, lib, config, pkgs, ... }:
{
  imports = [ ./zsh.nix ./neovim.nix ];

  ##################################################
  #                 BASIC SETTINGS                 #
  ##################################################
  nix = {
    package = lib.mkDefault pkgs.nix;
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
      # FIXME: Is it needed?
      # For ranger image preview
      # python3Packages.pillow
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

  programs.home-manager.enable = true;

  programs.ranger = {
    enable = true;
    settings = {
      preview_images = true;
      preview_images_method = "kitty";
      draw_borders = "both";
    };
  };

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
    settings.window_padding_width = 8;
    font = {
      size = 11;
      name = "Departure Mono";
      package = pkgs.departure-mono;
      # name = "CaskaydiaCove NF";
      # package = (pkgs.nerdfonts.override {
      #   fonts = [ "CascadiaCode" ];
      # });
    };
  };
}
