{ ... }:
{
  networking.hostName = "fractal";

  hardware.nvidia.open = true;

  services.xserver.videoDrivers = [ "nvidia" ];
}
