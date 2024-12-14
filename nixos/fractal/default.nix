{ ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "fractal";

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia.open = true;
}
