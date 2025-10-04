{ ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "metabox";

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia.open = true;
}
