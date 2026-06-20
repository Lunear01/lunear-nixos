# ROADMAP

Master TODO list + change log for this NixOS config. Codebase questions →
subdir `README.md` files and the top-level `README.md`.

## Open

_(none)_

## Recent changes

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
