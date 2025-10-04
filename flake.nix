{
  description = "A NixOS and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim/nixos-25.05";
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
      # Linux
      "i686-linux"
      "x86_64-linux"
      "aarch64-linux"
      # Darwin
      "x86_64-darwin"
      "aarch64-darwin"
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

    nixosConfigurations = {
      fractal = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs outputs; };
        modules = [ ./nixos/core ./nixos/fractal ];
      };
      zephyrus = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs outputs; };
        modules = [ ./nixos/core ./nixos/zephyrus ];
      };
      meta = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs outputs; };
        modules = [ ./nixos/core ./nixos/meta ];
      };
    };

    homeConfigurations = {
      ben = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = { inherit inputs outputs; };
        modules = [ ./home-manager/ben ];
        pkgs = pkgsFor.x86_64-linux;
      };
    };
  };
}
