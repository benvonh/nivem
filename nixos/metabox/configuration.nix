{ inputs, config, ... }:
{
  imports = [ inputs.private.nixosModules.server ];

  boot.extraModulePackages = [ config.boot.kernelPackages.tuxedo-drivers ];
  boot.kernelModules = [ "tuxedo_keyboards" "tuxedo_io" ];

  hardware.nvidia.open = false;

  networking.hostName = "metabox";
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
}
