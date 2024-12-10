# nivem

My Nix flake configurations for NixOS and Home Manager.

Features
- Hyprland and the Hypr suite;
- A modern shell experience with Zsh;
- Custom Nix packages built from source; and
- Neovim configured through Nixvim.

TODO: Add screenshots / videos

---
*What does "nivem" mean?*

"Nivem" is the accusative case of the word snow in Latin while "nix" is the nominative case.


## Online Install (Home Manager)

Install a configuration without cloning this repository.

:warning: Symlinks will be created in your home directory.

1. If Home Manager is not installed and flakes are not enabled, run
```bash
nix develop --extra-experimental-features 'nix-command flakes' github:benvonh/nivem
```

2. Install the Home Manager configuration of your choice.
```bash
home-manager switch --flake github:benvonh/nivem#$USER@$HOST
```
where `$USER@$HOST` is the `homeConfigurations` string in `flake.nix`.


## Full Install (Home Manager + NixOS)

Configure your NixOS system based off this flake.

1. Clone this repository and enter the custom shell.
```bash
# If not already installed
nix-shell -p git

git clone https://github.com/benvonh/nivem ~/nivem

cd ~/nivem

nix-shell
```

2. Create a NixOS configuration.
```bash
mkdir ~/nivem/nixos/$HOST

cp /etc/nixos/hardware-configuration.nix ~/nivem/nixos/$HOST

# Refer to an existing `default.nix` under `nixos/` to get started
vim ~/nivem/nixos/$HOST/default.nix
```

3. Create a Home Manager configuration.
```bash
mkdir ~/nivem/home-manager/$USER

# Refer to an existing `default.nix` under `home-manager/` to get started
vim ~/nivem/home-manager/$USER/default.nix
```

4. Add the configurations to the flake and switch to it.
```bash
vim ~/nivem/flake.nix

cd ~/nivem; git add .

sudo nixos-rebuild switch --flake ~/nivem

home-manager switch --flake ~/nivem
```
Append `#$HOST` and `#$USER@$HOST` to the switch commands (no space) if the correct values are not set in the environment variables.

### For The Impatient

If you want a quick start using my configurations,
replace the below references to `$USER` and `$HOST` in each of following files.

**NixOS**

[`flake.nix`](flake.nix)
```nix
nixosConfigurations = {
  $HOST = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs outputs; };
    modules = [ ./nixos/$HOST ];
  };
};
```
[`nixos/$HOST/default.nix`](nixos/zephyrus/default.nix)
```bash
networking.hostName = "$HOST";
...
users.users.$USER = {
  home = "/home/$USER";
};
```

**Home Manager**

[`flake.nix`](flake.nix)
```nix
homeConfigurations = {
  "$USER@$HOST" = home-manager.lib.homeManagerConfiguration {
    extraSpecialArgs = { inherit inputs outputs; };
    modules = [ ./home-manager/ben ];
    pkgs = pkgsFor.x86_64-linux;
  };
};
```
[`home-manager/$USER/default.nix`](home-manager/ben/default.nix)
```nix
home = {
  username = "$USER";
  homeDirectory = "/home/$USER";
};
```

:warning: Make sure to change personal settings such as Git username and imported NixOS hardware module.

---
Special thanks to [Misterio77](https://github.com/misterio77) for creating the [nix-starter-configs](https://github.com/misterio77/nix-starter-configs)!
