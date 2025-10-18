{
  description = "My NixOS and Home Manager configurations";

  inputs = {
    private.url = "path:private";

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

    hosts = [
      "fractal"
      "metabox"
      "zephyrus"
    ];

    pkgsFor = nixpkgs.legacyPackages;
    forAllSystems = nixpkgs.lib.genAttrs systems;
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

    nixosConfigurations = nixpkgs.lib.genAttrs hosts (host:
      nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs outputs host; };
        modules = [ ./nixos ];
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
