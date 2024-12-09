{ inputs, ... }:
{
  additions = final: prev: import ./pkgs.nix final.pkgs;

  modifications = final: prev: { };

  unstable-packages = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
    };
  };
}
