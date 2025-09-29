{ inputs, outputs, lib, config, pkgs, ... }:
let
  # default, rei, ken, silvia, catppuccin-[latte,...,mocha]
  sddm-theme = inputs.silent-sddm.packages.${pkgs.system}.default.override {
    theme = "default";
  };
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  
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

  nixpkgs.config.allowUnfree = true;

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
  #                 LOGIN MANAGER                 #
  #################################################
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = sddm-theme.pname;
    package = pkgs.kdePackages.sddm;
    extraPackages = sddm-theme.propagatedBuildInputs;
    settings = {
      General = {
        GreeterEnvironment = "QML2_IMPORT_PATH=${sddm-theme}/share/sddm/themes/${sddm-theme.pname}/components/,QT_IM_MODULE=qtvirtualkeyboard";
        InputMethod = "qtvirtualkeyboard";
      };
    };
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
    bibata-cursors
    discord
    gnome-calculator
    gnome-disk-utility
    gnome-system-monitor
    gpu-screen-recorder
    mission-center
    obs-studio
    sddm-theme
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
  # programs.nm-applet.enable = true;

  # We don't use nano here...
  programs.nano.enable = false;

  services.gvfs.enable = true;

  systemd.tmpfiles.rules = [
    "L /var/lib/AccountsService/icons/ben - - - - ${./assets/rezero.png}"
  ];

}
