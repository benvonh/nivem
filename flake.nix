{
  description = "Nix flake configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim/nixos-24.11";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    hyprpanel.url = "github:jas-singhfsu/hyprpanel";
    sugar-candy.url = "github:zhaith-izaliel/sddm-sugar-candy-nix";

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
    packages = forAllSystems (system: import ./pkgs.nix pkgsFor.${system});
    devShells = forAllSystems (system: import ./shell.nix pkgsFor.${system});

    overlays = import ./overlays.nix { inherit inputs; };

    nixosConfigurations = {
      zephyrus = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs outputs; };
        modules = [ ./nixos/zephyrus ];
      };
    };

    homeConfigurations = {
      "ben@zephyrus" = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = { inherit inputs outputs; };
        modules = [ ./home-manager/ben ];
        pkgs = pkgsFor.x86_64-linux;
      };
    };
  };
}
