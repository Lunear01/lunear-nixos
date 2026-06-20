# lunear-nixos

Personal NixOS configuration — a flake-based, modular setup with Home Manager,
running Hyprland on Wayland. Structured so new hosts, desktops, and users are a
few small edits rather than a copy-paste of the whole config.

## Layout

```
flake.nix            # inputs + auto-discovers every hosts/<host>/
lib/mkHost.nix       # nixosSystem factory (reads host vars, wires HM, pins registry)
lib/importAll.nix    # recursive .nix importer used by the module trees
themes/              # named base16 themes for the Stylix base layer
hosts/<host>/        # machine: vars.nix (settings) + hardware-configuration.nix + stateVersion
profiles/            # policy: aggregate modules and flip their enables
  ├── system/        #   desktop.nix, desktops/hyprland.nix
  └── user/          #   base.nix, desktops/hyprland.nix
modules/             # mechanism: one feature per module (auto-imported, option-guarded)
  ├── system/        #   core/* (always on) + desktop/* (lunear.* enable, default off)
  └── user/          #   shell, dev, apps/<enum>, desktop/<app>/ (+ dotfiles/)
users/<user>/        # user: NixOS account (default.nix) + vars.nix + HM identity (home.nix)
```

`system` = machine-wide (NixOS) layer; `user` = per-user (Home Manager) layer.
The same split names the module trees and the profiles, so it's obvious which
side a file belongs to.

The four layers:

| Layer | Role |
|-------|------|
| **`modules/`** | *Mechanism.* One feature per module. Both trees are blanket-imported via `lib/importAll.nix` and every module is option-guarded (`lunear.<area>.<feat>.enable`, default off) or choice-driven (`lunear.{browser,terminal,editor}`), so importing everything is safe — nothing activates until a profile flips it on. Drop a `.nix` file in, it's picked up. |
| **`profiles/`** | *Policy.* Aggregate module sets and turn features on (e.g. `profiles/system/desktops/hyprland.nix` enables the desktop baseline + Hyprland; `profiles/user/desktops/hyprland.nix` flips on the rice). |
| **`hosts/`** | *Identity.* Pick profiles, own `hardware-configuration.nix` and `system.stateVersion`. Per-machine settings (hostname, users, theme) live in `vars.nix`. |
| **`users/`** | *User.* `default.nix` is the NixOS account; `vars.nix` is the per-user settings (username, browser/terminal/editor, theme); `home.nix` is the Home Manager identity and the profiles it wants. |

### Settings (`vars.nix`)

Per-machine and per-user choices are plain-data attrsets, the single source of
truth threaded to every module:

- `hosts/<host>/vars.nix` → `systemSettings` (hostname, system, users, theme)
- `users/<user>/vars.nix` → `userSettings` (username, browser, terminal, editor, theme)

Switching a theme or browser is a one-word edit there; the `lunear.theme.name`
and `lunear.{browser,terminal,editor}` options default from these.

## Applying changes

```bash
nrs   # alias for: sudo nixos-rebuild --flake /etc/nixos#<hostname> switch
```

User programs and services are managed declaratively under `modules/user`
(`programs.*` / `services.*`) rather than as bare packages, so their config is
reproducible.

## Hyprland config

Desktop dotfiles live under their owning user module's `dotfiles/` directory
(e.g. `modules/user/desktop/waybar/dotfiles/`). They're deployed declaratively
via `xdg.configFile`, copied into the Nix store and symlinked into `~/.config/`.
Edits there take effect on the next `nrs`.

Files that need the real home path are run through the shared `themed` helper
(`modules/user/lib.nix`, exposed via `_module.args`), which substitutes `@home@`
at build time. Colors come from the selected Stylix base16 theme: kitty uses
Stylix's native target, while the custom-dotfile apps (waybar, rofi, swaync,
hyprland) read a `colors.*` file generated from the shared `palette` helper
(also in `modules/user/lib.nix`). Re-theming is `theme = "<name>";` + a rebuild.

## Adding things

- **A new host:** add a `hosts/<hostname>/` dir with `vars.nix` (settings),
  `hardware-configuration.nix`, and a `default.nix` importing the profiles it
  wants. `flake.nix` discovers it automatically — no flake edit.
- **A new user:** add `users/<user>/{default.nix,vars.nix,home.nix}` and list the
  username in the host's `vars.nix` `users`.
- **A headless server:** a `hosts/<server>/` whose `default.nix` imports no
  desktop profile — every `lunear.desktop.*` stays off, only `core/*` applies.
- **A new module:** drop a `.nix` file under `modules/system/` or `modules/user/`;
  the recursive importer picks it up. Guard it with `lunear.*.enable` (and flip it
  on in a profile) so it stays inert until wanted.

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
