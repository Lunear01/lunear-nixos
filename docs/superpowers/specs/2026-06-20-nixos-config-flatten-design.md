# NixOS config flatten — design

**Date:** 2026-06-20
**Status:** approved-pending-review
**Author:** Lunear01

## Problem

The current `/etc/nixos` flake is well-documented but over-abstracted for a single
maintainer who is new to Nix. To make a trivial change (e.g. enable bluetooth) you
touch two files — a module that declares a custom `lunear.*` option and a profile that
flips it on. Several indirection layers compound this:

- Custom option system: nearly every module wraps itself in `mkEnableOption`
  (`lunear.desktop.*`, `lunear.home.*`) and is turned on elsewhere.
- `profiles/` layer that only flips those options.
- `lib/importAll.nix` magic recursive auto-importer — hard to trace what loads.
- enum app-pickers (`browser`/`terminal`/`editor`) with `mkOption` + `mkMerge`.
- per-host vars merge hidden inside `lib/mkHost.nix`.

The structure is library-grade. For a personal 2-laptop daily driver it adds concepts
to learn without payoff (the user never disables bluetooth on one host only, never
toggles modules off, etc.).

## Goal

Flatten to a standard, beginner-friendly NixOS flake. **Behavior-preserving** —
pure restructure, no functional change to the built systems. Fewer concepts:
no custom option layer, no profiles, no magic import, no enums.

## Non-goals

- No change to what packages/services are installed or how the desktop looks.
- Not removing theme switching (kept).
- Not touching `hardware-configuration.nix` files.
- Not changing the bluetooth A2DP fix added earlier this session.

## Decisions (from brainstorming)

| Topic | Decision |
|---|---|
| Appetite | Big flatten — remove option wrappers, profiles, auto-importer |
| Themes | Keep the 9-theme registry + `theme = "name"` switching + palette plumbing |
| Variables | Keep `settings` arg from `vars.nix`; drop the auto-merge magic — merge explicitly in `flake.nix` |
| App enums | Hardcode actual choices: browser = zen (flatpak), terminal = kitty, editor = vscode |
| Hosts | Both laptops run the same Hyprland desktop via one shared `common.nix`; T14 differs only in display tuning (`scale`, `barFontPx`, `rofiFontPt`) carried in `hosts/thinkpad-t14/vars.nix` |

## Target layout

```
flake.nix              # lists both hosts explicitly, merges shared + host vars
vars.nix               # shared settings: username, theme, fonts, default display tuning
lib/mkHost.nix         # trivial factory: {hostname, settings} -> nixosSystem + home-manager wiring
common-system.nix      # shared system baseline imported by both hosts (replaces profiles/system)
common-home.nix        # shared home baseline imported by both hosts (replaces profiles/user)
hosts/
  rog-g14/
    configuration.nix       # imports common.nix + hardware; host-only system bits (asusd)
    hardware-configuration.nix
    home.nix                # host-only home extras
    vars.nix                # per-host overrides (monitor, scale)
  thinkpad-t14/
    configuration.nix
    hardware-configuration.nix
    home.nix
    vars.nix                # monitor, scale, barFontPx, rofiFontPt
modules/
  system/                   # plain NixOS modules, NO option wrappers
    boot.nix locale.nix networking.nix nix.nix nix-ld.nix security.nix
    audio.nix bluetooth.nix graphics.nix portal.nix files.nix flatpak.nix
    hyprland.nix inputmethod.nix stylix.nix
  home/                     # plain home-manager modules, NO option wrappers
    bash.nix dev.nix palette.nix stylix-targets.nix
    hyprland/ rofi/ waybar/ swaync/ fcitx5/ kitty/   (each + its dotfiles/)
themes/                     # unchanged registry (switching preserved)
users/
  lunear.nix                # user account (users.users.lunear)
```

Removed vs today: `profiles/` (3 files), `lib/importAll.nix`, the
`modules/user/apps/{browser,terminal,editor}` enum modules, and every custom
`options.lunear.* = mkEnableOption / mkOption` block inside the modules.

## How key mechanisms change

### Module application
Before: module declares `options.lunear.X.enable`; a profile sets it true; body is
`config = lib.mkIf cfg.enable { ... }`.
After: module body is just `{ ... }` (the config attrs directly). It applies because
`common.nix` (or a host) imports it. To stop using one, remove its import line.

### Shared baseline (replaces both profiles)
Two small files, each a plain `imports` list:
- `common-system.nix` — the shared system baseline (replaces
  `profiles/system/hyprland.nix`); imported by each host's `configuration.nix`.
- `common-home.nix` — the shared home baseline (replaces `profiles/user/base.nix`
  + `profiles/user/hyprland.nix`); imported by each host's `home.nix`.

Two files (not one) because the system and home module sets are imported into two
different evaluation contexts (NixOS vs home-manager); keeping them separate avoids
a combined file that must be sliced apart at the import site.

### Variables / per-host
`flake.nix`:
```nix
let shared = import ./vars.nix; in {
  nixosConfigurations.rog-g14 =
    mkHost { hostname = "rog-g14"; settings = shared // import ./hosts/rog-g14/vars.nix; };
  nixosConfigurations.thinkpad-t14 =
    mkHost { hostname = "thinkpad-t14"; settings = shared // import ./hosts/thinkpad-t14/vars.nix; };
}
```
`settings` stays a specialArg, so modules keep reading `settings.scale`,
`settings.rofiFontPt`, etc. unchanged. The only difference: the shared+host merge is
visible in `flake.nix` rather than hidden via `readDir` in `mkHost`. `mkHost` no
longer discovers hosts or reads vars files.

### Apps (enums removed)
- browser zen: `services.flatpak.packages = [ "app.zen_browser.zen" ];` placed in the
  home baseline directly (no enum).
- terminal kitty: the existing `kitty` home module (unconditional).
- editor vscode: enable directly in the home baseline / dev module.

### Stylix
`modules/system/stylix.nix`: drop `lunear.theme.stylix.enable` and the
`lunear.theme.name` option; read the selected theme directly:
`theme = themes.${settings.theme}`. Switching still works by editing `vars.nix`
`theme = "..."`. `modules/home/stylix-targets.nix`: drop the enable option, apply the
target policy directly. `palette.nix` (`themed`/`palette`/`paletteRaw` via
`_module.args`) is unchanged — the custom-dotfile apps still consume it.

## Safety plan (daily driver)

This is the user's running system. Migration must not change the built result.

1. Work on a git branch.
2. Build the **current** config first and record the store path:
   `nix build .#nixosConfigurations.rog-g14.config.system.build.toplevel` → save path
   (repeat for thinkpad-t14).
3. Perform the flatten.
4. Build the **new** config the same way.
5. **Diff the derivations** with `nvd diff <old> <new>` (and/or compare toplevel store
   paths). Expected: empty or only-trivial diff. Investigate any real difference before
   proceeding.
6. Only `nixos-rebuild switch` after the diff is clean.
7. Preserve the bluetooth A2DP wireplumber settings added earlier (they live in the
   bluetooth module — carry verbatim).

## Success criteria

- `nix flake check` passes; both hosts build.
- `nvd diff` between pre- and post-flatten toplevel is empty/trivial for both hosts.
- No file declares a custom `lunear.*` option; no `profiles/`, no `importAll.nix`,
  no app enum modules remain.
- Theme switching still works by editing `vars.nix`.
- Adding a new module is: create the file, add one import line — one file to find.
