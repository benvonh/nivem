{ inputs, outputs, lib, config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix
    inputs.sugar-candy.nixosModules.default
    inputs.hardware.nixosModules.asus-zephyrus-ga402
  ];

  ################################################
  #                 NIX SETTINGS                 #
  ################################################
  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

    channel.enable = false;

    settings = {
      flake-registry = "";
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";
      nix-path = config.nix.nixPath;
    };

    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "-d --repair";
      randomizedDelaySec = "45min";
    };
  };

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config.allowUnfree = true;
  };

  ###################################################
  #                 SYSTEM SETTINGS                 #
  ###################################################
  system.stateVersion = "24.11";

  i18n.defaultLocale = "en_AU.UTF-8";

  time.timeZone = "Australia/Brisbane";

  networking.hostName = "zephyrus";
  networking.networkmanager.enable = true;

  ###############################################
  #                 BOOT LOADER                 #
  ###############################################
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 3;
    efi.canTouchEfiVariables = true;
  };

  boot.plymouth = {
    enable = true;
    theme = "colorful_loop";
    themePackages = [
      (pkgs.adi1090x-plymouth-themes.override {
        selected_themes = [ "colorful_loop" ];
      })
    ];
  };

  ############################################
  #                 SERVICES                 #
  ############################################
  services.blueman.enable = true;
  services.libinput.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    sugarCandyNix = {
      enable = true;
      settings = {
        PartialBlur = true;
        ScreenWidth = 1920;
        ScreenHeight = 1200;
        MainColor = "#5277C3"; 
        AccentColor = "#7EBAE4";
        HaveFormBackground = true;
        Background = lib.cleanSource ./sddm-wallpaper.jpg;
        HeaderText = "nivem 󱄅 ";
        Font = "CaskaydiaCove NF";
      };
    };
  };

  security.rtkit.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;
  hardware.pulseaudio.enable = false;

  ####################################################
  #                 USER APPLICATION                 #
  ####################################################
  users.users.ben = {
    shell = pkgs.zsh;
    home = "/home/ben";
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # NOTE: `fc-cache -r`
  fonts = {
    packages = with pkgs; [
      ubuntu-sans
      (nerdfonts.override {
        fonts = [ "CascadiaCode" ];
      })
    ];
    fontconfig.defaultFonts = {
      serif = [ "Ubuntu Sans" ];
      sansSerif = [ "Ubuntu Sans" ];
      monospace = [ "CaskaydiaCove NF" ];
    };
  };

  environment.systemPackages = with pkgs; [
    gnome-system-monitor
    gnome-disk-utility
    gnome-calculator
    nautilus
    neovide 
    discord 
    brave 
  ];

  programs.vim.enable = true;
  programs.git.enable = true;
  programs.zsh.enable = true;
  programs.hyprland.enable = true;
  programs.nm-applet.enable = true;

  # We don't use nano here...
  programs.nano.enable = false;

  xdg.portal.wlr.enable = true;
}
