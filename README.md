# lunear-nixos

Personal NixOS configuration — a flake-based setup with Home Manager, running
Hyprland on Wayland.

## Layout

| File | Purpose |
|------|---------|
| `flake.nix` | Entry point; wires nixpkgs + Home Manager into the `lunear-nixos` host. |
| `configuration.nix` | System config — boot, networking, services, system packages. |
| `hardware-configuration.nix` | **Machine-specific** (disks, kernel modules). Regenerate per machine. |
| `home.nix` | Home Manager — user programs, services, and dotfiles. |
| `hypr/hyprland.lua` | Hyprland config, symlinked live into `~/.config/hypr/`. |

## Applying changes

```bash
nrs   # alias for: sudo nixos-rebuild --flake /etc/nixos#lunear-nixos switch
```

User programs and services are managed declaratively in `home.nix`
(`programs.*` / `services.*`) rather than as bare packages, so their config is
reproducible.

## Hyprland config

`hypr/hyprland.lua` is deployed via a Home Manager out-of-store symlink, so
`~/.config/hypr/hyprland.lua` points straight at the repo file. Edit it in place
and changes apply on the next Hyprland reload — no rebuild needed. This requires
the repo to live at `/etc/nixos`.

## Reinstalling on a new machine

```bash
# After a minimal NixOS install:
sudo nixos-generate-config                  # initial hardware config
sudo rm -rf /etc/nixos
sudo git clone https://github.com/Lunear01/lunear-nixos.git /etc/nixos

# Regenerate hardware-configuration.nix for THIS machine (disk UUIDs differ):
sudo nixos-generate-config --show-hardware-config > /etc/nixos/hardware-configuration.nix

sudo nixos-rebuild switch --flake /etc/nixos#lunear-nixos
```

> ⚠️ Always regenerate `hardware-configuration.nix` on new hardware — the
> committed copy is specific to the original machine and may prevent boot.
