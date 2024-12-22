{ inputs, outputs, lib, config, pkgs, ... }:
let
  host = config.networking.hostName;
in
{
  imports = [
    inputs.sugar-candy.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
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

  networking.networkmanager.enable = true;

  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 3;
    efi.canTouchEfiVariables = true;
  };

  ############################################
  #                 SERVICES                 #
  ############################################
  services.gvfs.enable = true;
  services.hypridle.enable = true;

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
      settings = let
        resolutionForHost = {
          zephyrus = { w = 1920; h = 1200; };
          fractal = { w = 1920; h = 1080; };
        };
        resolution = if builtins.hasAttr host resolutionForHost then
          builtins.getAttr host resolutionForHost
        else throw "[nivem] unknown host ${host} for resolution";
      in {
        AccentColor = "#CFDBE5";
        Background = lib.cleanSource ./assets/norway-river.jpg;
        BackgroundColor = "#000000";
        Font = "CaskaydiaCove NF";
        HaveFormBackground = true;
        HeaderText = "Welcome to nivem";
        MainColor = "#CFDBE5"; 
        PartialBlur = true;
        ScreenHeight = resolution.h;
        ScreenWidth = resolution.w;
      };
    };
  };

  security.rtkit.enable = true;
  hardware.pulseaudio.enable = false;

  ####################################################
  #                 USER APPLICATION                 #
  ####################################################
  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; host = host; };
    users.ben.imports = [ ./home.nix ./hypr.nix ../../home-manager/ben ];
    backupFileExtension = "hm.backup";
  };

  users.users.ben = {
    shell = pkgs.zsh;
    home = "/home/ben";
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # NOTE: fontconfig tips...
  # fc-cache -r
  # fc-list | bat
  # fc-match 'font name'
  fonts = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
      noto-fonts-monochrome-emoji
      noto-fonts-emoji-blob-bin
      noto-fonts-color-emoji
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-lgc-plus
      noto-fonts
    ];
    fontconfig.defaultFonts = {
      monospace = [ "CaskaydiaCove NF" ];
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
    };
  };

  environment.systemPackages = with pkgs; [
    libsForQt5.qt5.qtgraphicaleffects
    # TODO: Where is the best place for these?
    gnome-system-monitor
    gnome-disk-utility
    gnome-calculator
    mission-center
    obs-studio
    celluloid
    libnotify
    nautilus
    neovide 
    discord 
    brave 
  ];

  programs.git.enable = true;
  programs.vim.enable = true;
  programs.zsh.enable = true;
  programs.steam.enable = true;
  programs.hyprland.enable = true;
  programs.hyprlock.enable = true;
  programs.nm-applet.enable = true;

  # We don't use nano here...
  programs.nano.enable = false;

  xdg.portal.wlr.enable = true;
}
