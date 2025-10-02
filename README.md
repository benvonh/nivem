> *nivem*: accusative singular of *nix* :snowflake:

# nivem

My NixOS and Home Manager configurations in a Nix flake.


Features:
- Hyprland
- Caelestia Shell
- Nixvim


https://github.com/user-attachments/assets/682b669c-7ae4-4cf6-b765-6b186498363f


## Installation

<details>
<summary>Online Install (Home Manager)</summary>
*Install a configuration without cloning the repository.*

1. If not already done, enable flakes and prepare Home Manager.
```sh
nix develop --extra-experimental-features 'nix-command flakes' github:benvonh/nivem
```

2. Install the Home Manager configuration of your choice.
```sh
home-manager switch --flake github:benvonh/nivem#your-config
```

You may omit `#your-config` to default to `$USER`.


</details>

<details>
<summary>Full Install (NixOS)</summary>
*Install a configuration locally for NixOS and Home Manager.*

1. Clone this repository and enter my custom shell.
```sh
git clone https://github.com/benvonh/nivem ~/nivem
nix develop --extra-experimental-features 'nix-command flakes' ~/nivem
```

2. Create a Home Manager configuration.
```sh
mkdir ~/nivem/home-manager/$USER

# See other configs for reference
vim ~/nivem/home-manager/$USER/default.nix
```

3. Create a NixOS configuration.
```sh
mkdir ~/nivem/nixos/$HOST
cp /etc/nixos/hardware-configuration.nix ~/nivem/nixos/$HOST

# See other configs for reference
vim ~/nivem/nixos/$HOST/default.nix
```

4. Add the configurations to the flake and switch to it.
```sh
vim ~/nivem/flake.nix

cd ~/nivem
git add .

sudo nixos-rebuild switch --flake ~/nivem#your-config
```

You may omit `#your-config` to default to `$HOST`. Note that this NixOS setup imports Home Manager internally.

:warning: Make sure to change personal settings such as Git username and hardware modules.
</details>

---
Special thanks to [Misterio77](https://github.com/misterio77) for his [nix-starter-configs](https://github.com/misterio77/nix-starter-configs)!
