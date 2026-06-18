# lunear-nixos

Personal NixOS configuration — a flake-based, modular setup with Home Manager,
running Hyprland on Wayland. Structured so new hosts, desktops, and users are a
few small edits rather than a copy-paste of the whole config.

## Layout

```
flake.nix            # inputs + one mkHost call per host
lib/mkHost.nix       # nixosSystem factory (HM wiring, registry pin, nixPath)
hosts/<host>/        # machine identity: imported profiles, hardware, stateVersion
profiles/            # policy: aggregate modules and flip their enables
  ├── nixos/         #   desktop.nix, desktops/hyprland.nix
  └── home/          #   base.nix, desktops/hyprland.nix
modules/             # mechanism: one feature per module
  ├── nixos/         #   core/* (always on) + desktop/* (lunear.* enable, default off)
  └── home/          #   shell, dev, desktop/<app>/ (+ dotfiles/)
users/<user>/        # host-independent user: NixOS account + HM identity/profiles
```

The four layers:

| Layer | Role |
|-------|------|
| **`modules/`** | *Mechanism.* Each feature is one module. NixOS desktop modules are option-guarded (`lunear.<area>.<feat>.enable`, default off) and blanket-imported, so a host that wants none of them stays clean. Home modules are imported selectively by home profiles. |
| **`profiles/`** | *Policy.* Aggregate module sets and turn features on (e.g. `profiles/nixos/desktops/hyprland.nix` enables the desktop baseline + Hyprland). |
| **`hosts/`** | *Identity.* Pick profiles, own `hardware-configuration.nix` and `system.stateVersion`. Hostname and users come from the `mkHost` call. |
| **`users/`** | *User.* `default.nix` is the NixOS account; `home.nix` is the Home Manager identity (`home.stateVersion`, etc.) and the home profiles it wants. |

## Applying changes

```bash
nrs   # alias for: sudo nixos-rebuild --flake /etc/nixos#<hostname> switch
```

User programs and services are managed declaratively under `modules/home`
(`programs.*` / `services.*`) rather than as bare packages, so their config is
reproducible.

## Hyprland config

Desktop dotfiles live under their owning home module's `dotfiles/` directory
(e.g. `modules/home/desktop/waybar/dotfiles/`). They're deployed declaratively
via `xdg.configFile`, copied into the Nix store and symlinked into `~/.config/`.
Edits there take effect on the next `nrs`.

Files that need the real home path are run through the shared `themed` helper
(`modules/home/lib.nix`, exposed via `_module.args`), which substitutes `@home@`
at build time. Runtime theming is unaffected: wallust writes its generated
palette to `~/.cache/wal/`, which these configs `@import`/`include`, so
re-theming the desktop still happens live without a rebuild.

## Adding things

- **A new host:** add one `mkHost { hostname = "..."; users = [ ... ]; }` line in
  `flake.nix` and a `hosts/<hostname>/` dir (imported profiles + hardware +
  `system.stateVersion`).
- **A new user:** add `users/<user>/{default.nix,home.nix}` and list them in the
  host's `mkHost` `users`.
- **A headless server:** a `hosts/<server>/` that imports no desktop profile —
  every `lunear.desktop.*` stays off, only `core/*` applies.

## Reinstalling on a new machine

```bash
# After a minimal NixOS install:
sudo nixos-generate-config                  # initial hardware config
sudo rm -rf /etc/nixos
sudo git clone https://github.com/Lunear01/lunear-nixos.git /etc/nixos

# Regenerate hardware config for THIS machine (disk UUIDs differ):
sudo nixos-generate-config --show-hardware-config \
  > /etc/nixos/hosts/lunear-nixos/hardware-configuration.nix

sudo nixos-rebuild switch --flake /etc/nixos#lunear-nixos
```

> ⚠️ Always regenerate `hardware-configuration.nix` on new hardware — the
> committed copy is specific to the original machine and may prevent boot.
