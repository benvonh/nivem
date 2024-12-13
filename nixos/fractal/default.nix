{ inputs, outputs, lib, config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix
    inputs.sugar-candy.nixosModules.default
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

  networking.hostName = "fractal";
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
        # TODO: Check if this is good
        PartialBlur = true;
        # FullBlur = true;
        # BlurRadius = 35;
        ScreenWidth = 1920;
        ScreenHeight = 1200;
        # MainColor = "#7EBAE4"; 
        MainColor = "#B3BEC7"; 
        AccentColor = "#F2F2E9";
        BackgroundColor = "#000000";
        # ScaleImageCropped = false;
        HaveFormBackground = true;
        Background = lib.cleanSource ./norway-river-view.jpg;
        HeaderText = "nivem";
        Font = "CaskaydiaCove NF";
      };
    };
  };

  security.rtkit.enable = true;
  hardware.pulseaudio.enable = false;

  # NVIDIA
  # hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;

  ####################################################
  #                 USER APPLICATION                 #
  ####################################################
  users.users.ben = {
    shell = pkgs.zsh;
    home = "/home/ben";
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "plugdev"
      "input"
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
    libsForQt5.qt5.qtgraphicaleffects
    gnome-system-monitor
    gnome-disk-utility
    gnome-calculator
    youtube-music
    obs-studio
    celluloid
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
