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
  in
  {
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;

    channel.enable = false;
    optimise.automatic = true;

    settings = {
      nix-path = config.nix.nixPath;
      flake-registry = "";
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";
    };
  };

  nixpkgs = {
    overlays = [
      inputs.hyprpanel.overlay
      inputs.ulauncher.overlays.default
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

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.displayManager.sddm = {
    enable = true;
    wayland = {
      enable = true;
      compositor = "kwin";
    };
    settings.Theme =  {
      CursorTheme = "Bibata-Modern-Ice";
      CursorSize = 20;
    };
    sugarCandyNix = {
      enable = true;
      settings = let
        resolutionForHost = {
          fractal = { w = 1920; h = 1080; };
          zephyrus = { w = 1920; h = 1200; };
        };
        resolution =
          if resolutionForHost ? ${host} then
            resolutionForHost.${host}
          else
            throw "[nivem] host = ${host}";
      in {
        Font = "CaskaydiaCove NF";
        MainColor = "#E9F5FF"; 
        Background = lib.cleanSource ./assets/norway-river.jpg;
        HeaderText = "Powered by nivem  ";
        AccentColor = "#E9FFF5";
        PartialBlur = true;
        ScreenWidth = resolution.w;
        ScreenHeight = resolution.h;
        BackgroundColor = "#000000";
        HaveFormBackground = true;
      };
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 5;
      efi.canTouchEfiVariables = true;
    };
    # Fixes audio popping on suspend/resume playback
    extraModprobeConfig = "options snd_hda_intel power_save=0";
    # Mounts '/tmp' to RAM
    tmp.useTmpfs = true;
  };

  #################################################
  #                 USER SETTINGS                 #
  #################################################
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs outputs; };
    users.ben.imports = [
      ../../home-manager/ben
      ./home.nix 
      ./hypr.nix
    ];
    backupFileExtension = "bak";
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
  # `fc-cache -r`
  # `fc-list | bat`
  # `fc-match 'font name'`
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

  environment.sessionVariables.XCURSOR_THEME = "Bibata-Modern-Ice";

  environment.systemPackages = with pkgs; [
    # TODO: Uhhh do I still need?
    # libsForQt5.qt5.qtgraphicaleffects
    # TODO: Where is the best place for these?
    gnome-system-monitor
    gnome-disk-utility
    gnome-calculator
    mission-center
    bibata-cursors
    obs-studio
    celluloid
    libnotify
    nautilus
    discord 
    brave 
  ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  programs.git.enable = true;
  programs.vim.enable = true;
  programs.zsh.enable = true;
  programs.uwsm.enable = true;
  programs.steam.enable = true;
  programs.hyprlock.enable = true;
  programs.nm-applet.enable = true;

  # We don't use nano here...
  programs.nano.enable = false;

  services.gvfs.enable = true;
  services.hypridle.enable = true;
}
