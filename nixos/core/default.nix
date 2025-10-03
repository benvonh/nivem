{ inputs, outputs, lib, config, pkgs, ... }:
let
  # default, rei, ken, silvia, catppuccin-[latte,...,mocha]
  sddm-theme = inputs.silent-sddm.packages.${pkgs.system}.default.override { theme = "rei"; };
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

  security.polkit = {
    enable = true;
    package = pkgs.mate.mate-polkit;
  };

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

  users.users = {
    root.initialPassword = "nixos";
    ben = {
      shell = pkgs.zsh;
      home = "/home/ben";
      isNormalUser = true;
      initialPassword = "nixos";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };
  };

  fonts = {
    packages = with pkgs; [
      liberation_ttf
      nerd-fonts.caskaydia-cove
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      noto-fonts-emoji-blob-bin
      noto-fonts-lgc-plus
      noto-fonts-monochrome-emoji
      texlivePackages.nunito
      times-newer-roman
    ];
    fontconfig.defaultFonts = {
      monospace = [ "CaskaydiaCove NF" ];
      sansSerif = [ "Nunito" ];
      serif = [ "Times Newer Roman" ];
    };
  };

  environment.sessionVariables.XCURSOR_THEME = "Bibata-Modern-Ice";

  environment.systemPackages = with pkgs; [
    inputs.quickshell.${system}.package
    bibata-cursors
    clapper
    discord
    gnome-calculator
    gnome-disk-utility
    gnome-system-monitor
    gpu-screen-recorder-gtk
    loupe
    mission-center
    nautilus
    obs-studio
    pavucontrol
    sddm-theme
    vscode
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
  programs.gpu-screen-recorder.enable = true;

  # We don't use nano here...
  programs.nano.enable = false;

  services.gvfs.enable = true;

  systemd.tmpfiles.rules = [
    "L /var/lib/AccountsService/icons/ben - - - - ${../../asset/rezero.png}"
  ];
}
