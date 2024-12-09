{ inputs, outputs, lib, config, pkgs, ... }:
{
  imports = [
    ./zsh.nix
    ./neovim.nix
    ./hyprland.nix
  ];

  nix.package = pkgs.nix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.overlays = [
    outputs.overlays.additions
    outputs.overlays.modifications
    outputs.overlays.unstable-packages
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "Ubuntu Sans" ];
      sansSerif = [ "Ubuntu Sans" ];
      monospace = [ "Departure Mono" ];
    };
  };

  home = {
    username = "ben";
    homeDirectory = "/home/ben";
    stateVersion = "24.11";
    packages = with pkgs; [
      nodejs
      tldr htop ranger
      wl-clipboard
    ];
  };

  programs.home-manager.enable = true;
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
      name = "CaskaydiaCove Nerd Font";
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
    font = "CaskaydiaCove Nerd Font";
    theme = ./rofi.rasi;
  };

  systemd.user.startServices = "sd-switch";
}
