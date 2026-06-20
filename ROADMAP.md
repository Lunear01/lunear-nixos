# ROADMAP

Master TODO list + change log for this NixOS config. Codebase questions →
subdir `README.md` files and the top-level `README.md`.

## Open

_(none)_

## Recent changes

- **Consolidated profiles; one dir per machine.** Cut layer-bounce + the
  host split-brain (system half in `hosts/`, user half in `profiles/user/hosts/`).
  - `profiles/user/hosts/<h>.nix` → `hosts/<h>/home.nix` (everything about a
    machine now lives in `hosts/<h>/`; `home.nix` discovers it by hostname).
  - Merged `profiles/system/desktop.nix` into `profiles/system/hyprland.nix`;
    flattened the single-child `desktops/` dirs (`profiles/{system,user}/hyprland.nix`).
  - Profiles tree: 6 files → 3. No behavior change.
  - Verified: both hosts' `…toplevel.drvPath` evaluate.

- **Removed wallust; Stylix-only theming.** The selected base16 theme
  (`lunear.theme.name`) is now the single color source for the whole desktop.
  - Added `palette`/`paletteRaw` helpers to `modules/user/lib.nix` (standard
    base16→16-color mapping from `config.lib.stylix.colors`).
  - kitty → native Stylix target (opacity via `stylix.opacity.terminal`).
  - waybar/swaync/rofi/hyprland keep their custom liquid-glass dotfiles but read
    a generated `colors.*` file built from the Stylix palette instead of
    `~/.cache/wal/`.
  - Dropped the `wallust` package, `wallust.toml` + templates dir, and the
    `wallust run` step from `theme.sh` (awww wallpaper switching kept).
  - Verified: `nix build .#nixosConfigurations.lunear-nixos…toplevel` succeeds.
