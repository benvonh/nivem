{ ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "fractal";

  services.xserver.videoDrivers = [ "nvidia" ];

  # hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.open = true;
}
