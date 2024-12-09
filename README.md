# nivem

My Nix flake configurations for NixOS and Home Manager. Features Hyprland and the Hypr suite, a modern shell experience in Zsh, custom Nix packaging and Neovim with Nixvim.

TODO: Add screenshots / videos

---
*What does "nivem" mean?*

"Nivem" is the accusative of the word snow in Latin while "nix" is the nominative.


## Online Install (Home Manager)

Install a configuration without cloning this repository.

:warning: Symlinks will be created in your home directory.

1. If Home Manager is not installed and flakes are not enabled, run
```
nix develop --extra-experimental-features 'nix-command flakes' github:benvonh/nivem
```

2. Install the Home Manager configuration of your choice.
```
home-manager switch --flake github:benvonh/nivem#$USER@$HOST
```
where \$USER@$HOST is the `homeConfiguration` string in `flake.nix`.


## Full Install (Home Manager + NixOS)

Configure your NixOS system based off of this flake.

1. Clone this repository and enter the custom shell.
```
# If not already installed
nix-shell -p git

git clone https://github.com/benvonh/nivem ~/nivem

cd ~/nivem

nix-shell
```

2. Create a NixOS configuration.
```
mkdir ~/nivem/nixos/$HOST

cp /etc/nixos/hardware-configuration.nix ~/nivem/nixos/$HOST

# Refer to an existing `default.nix` under `nixos/` to get started
vim ~/nivem/nixos/$HOST/default.nix
```

3. Create a Home Manager configuration.
```
mkdir ~/nivem/home-manager/$USER

# Refer to an existing `default.nix` under `home-manager/` to get started
vim ~/nivem/home-manager/$USER/default.nix
```

4. Add the configurations to the flake and switch to it.
```
vim ~/nivem/flake.nix

cd ~/nivem; git add .

sudo nixos-rebuild switch --flake ~/nivem

home-manager switch --flake ~/nivem
```
Append `#$HOST` and `#$USER@$HOST` to the switch commands (no space) if the correct values are not set in the environment variables.
