TODO: REVISE WHOLE THING
# nivem

My NixOS and Home Manager configurations in a Nix flake.

Features
- Hyprland and the Hypr suite;
- A modern shell experience in Zsh;
- Custom Nix packages built from source; and
- Neovim configured with the Nixvim module.

TODO: Add screenshots / videos

---
*What does "nivem" mean?*

"Nivem" is the accusative case of the word *snow* in Latin whereas "nix" is the nominative case.
So they mean the same thing but "nix" is the *subject* and "nivem" is the *object*... very poetic :snowflake:



## Online Install (Home Manager)

**Install a configuration without cloning this repository.**

:warning: Symlinks will be created in your home directory.

1. If Home Manager is not installed and experimental features are not enabled, run
```sh
nix develop --extra-experimental-features 'nix-command flakes' github:benvonh/nivem
```

2. Install the Home Manager configuration of your choice.
```sh
home-manager switch --flake github:benvonh/nivem#$USER
```
where `$USER` is an attribute in the `homeConfigurations` set inside the `flake.nix` file.

May be omitted to automatically read from the shell environment.



## Standalone Install (Home Manager)

**Configure Home Manager on a non-NixOS system.**

:warning: Symlinks will be created in your home directory.

1. Clone this repository; and enter the custom shell if experimental features are not enabled.
```sh
git clone https://github.com/benvonh/nivem ~/nivem

# For noobs
nix develop --extra-experimental-features 'nix-command flakes' ~/nivem
```

2. Create a Home Manager configuration and add to the flake.
```sh
mkdir ~/nivem/home-manager/$USER

# Create configuration...
# Refer to 

# Add to 'homeConfigurations'
vim ~/nivem/flake.nix
```

3. Install the Home Manager configuration.
```sh
home-manager switch --flake .#$USER@$HOST
```
where `$USER` is an attribute in the `homeConfigurations` set inside the `flake.nix` file.

## Full Install (Home Manager + NixOS)

**Configure NixOS and Home Manager locally through this flake.**

1. Clone this repository.
```bash
git clone https://github.com/benvonh/nivem ~/nivem
```

2. Create a NixOS configuration.
```bash
mkdir ~/nivem/nixos/$HOST

cp /etc/nixos/hardware-configuration.nix ~/nivem/nixos/$HOST

# Refer to an existing `default.nix` under `nixos/` to get started
vim ~/nivem/nixos/$HOST/default.nix
```

4. Add the configuration to the flake and switch to it.
```bash
vim ~/nivem/flake.nix

cd ~/nivem; git add .

sudo nixos-rebuild switch --flake ~/nivem
```
Append `#$HOST` and `#$USER@$HOST` to the switch commands (no space) if the correct values are not set in the environment variables.

---
### For The Impatient

If you want a quick start to using my configurations,
replace the below references, `$USER` and `$HOST`, in each of the files.

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

:warning: Make sure to change personal settings such as Git username and imported NixOS hardware modules.

---
Special thanks to [Misterio77](https://github.com/misterio77) for creating the [nix-starter-configs](https://github.com/misterio77/nix-starter-configs)!
