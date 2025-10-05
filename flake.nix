{
  description = "My NixOS and Home Manager configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    silent-sddm.url = "github:uiriansan/silentsddm";
    silent-sddm.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    caelestia-shell.url = "github:caelestia-dots/shell";

    hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    inherit (self) outputs;

    systems = [
      "i686-linux"
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    pkgsFor = nixpkgs.legacyPackages;
    forAllSystems = nixpkgs.lib.genAttrs systems;

    perHost = {
      fractal = [
        {
          networking.hostName = "fractal";
          services.xserver.videoDrivers = [ "nvidia" ];
          hardware.nvidia.open = false;
        }
      ];
      zephyrus = [
        inputs.hardware.nixosModules.asus-zephyrus-ga402
        {
          networking.hostName = "zephyrus";

          services.upower.enable = true;
          services.libinput.enable = true;
          services.power-profiles-daemon.enable = true;

          hardware.bluetooth.enable = true;
          hardware.bluetooth.powerOnBoot = false;
        }
      ];
      metabox = [
        {
          networking.hostName = "metabox";
          services.xserver.videoDrivers = [ "nvidia" ];
          hardware.nvidia.open = true;
          services.openssh.enable = true;
        }
      ];
    };
  in
  {
    packages = forAllSystems (system:
      let pkgs = pkgsFor.${system}; in {
        cheat = pkgs.callPackage ./cheat {};
      });

    devShells = forAllSystems (system:
      let pkgs = pkgsFor.${system}; in {
        default = pkgs.mkShell {
          NIX_CONFIG = "experimental-features = nix-command flakes";
          packages = [ pkgs.nix pkgs.git pkgs.vim pkgs.home-manager ];
        };
      });

    nixosConfigurations = nixpkgs.lib.genAttrs (builtins.attrNames perHost) (hostname:
      nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs outputs; };
        modules = (perHost.${hostname} or []) ++ [
          ./nixos/${hostname}.nix
          # (./nixos + "/${hostname}.nix")
          ./nixos/core.nix
        ];
      });

    homeConfigurations = {
      ben = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = { inherit inputs outputs; };
        modules = [
          ./home-manager/core.nix
          ./home-manager/neovim.nix
        ];
        pkgs = pkgsFor.x86_64-linux;
      };
    };
  };
}
