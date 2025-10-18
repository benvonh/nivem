{ inputs, ... }:
{
  imports = [ inputs.hardware.nixosModules.asus-zephyrus-ga402 ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  networking.hostName = "zephyrus";

  services.libinput.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
}
