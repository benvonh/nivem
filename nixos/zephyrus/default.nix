{ inputs, ... }:
{
  imports = [ ./hardware-configuration.nix
    inputs.hardware.nixosModules.asus-zephyrus-ga402
  ];

  networking.hostName = "zephyrus";

  programs.nm-applet.enable = true;

  services.upower.enable = true;
  services.blueman.enable = true;
  services.libinput.enable = true;
  services.power-profiles-daemon.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;
}
