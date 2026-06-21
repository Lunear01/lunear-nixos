# NixOS Config Flatten Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Flatten the over-abstracted `/etc/nixos` flake into a standard beginner-friendly layout with no behavior change to the built systems.

**Architecture:** Remove the custom `lunear.*` option layer, the `profiles/` indirection, the `lib/importAll.nix` magic importer, and the browser/terminal/editor enum modules. Modules become plain (apply when imported). A shared `common-system.nix` + `common-home.nix` replace the profiles. `flake.nix` lists both hosts explicitly and merges `vars.nix` with per-host `vars.nix`. The `settings` arg and theme switching are preserved.

**Tech Stack:** Nix flakes, NixOS unstable, home-manager, Stylix, nix-flatpak.

## Global Constraints

- **Behavior-preserving.** The build output must not change. The gate for every code task is: `nvd diff` between the pre-flatten baseline and the new build shows no real differences (empty, or only unrelated version noise). Inputs (`flake.lock`) are NOT updated during this work.
- **Commits:** author + committer = `Lunear01` only. NEVER add `Co-Authored-By:` trailers or any "Generated with Claude" line. Verify with `git log -1 --format='%an <%ae>%n%b'` after committing.
- **Do not edit** `hosts/*/hardware-configuration.nix`.
- **Preserve verbatim** the bluetooth A2DP wireplumber settings currently in `modules/system/desktop/bluetooth.nix` (the `services.pipewire.wireplumber.extraConfig."51-bluez-a2dp"` block and `hardware.bluetooth.settings.General.Experimental`).
- Branch: `config-flatten` (already checked out).
- The mechanical "de-option" transform (used in Tasks 2 and 3):
  > Given a module shaped as
  > ```nix
  > { lib, config, ... }:
  > let cfg = config.lunear.X; in
  > { options.lunear.X.enable = lib.mkEnableOption "..."; config = lib.mkIf cfg.enable { BODY }; }
  > ```
  > rewrite it to
  > ```nix
  > { ... }:                # keep only args BODY actually uses
  > { BODY }                # BODY unindented one level
  > ```
  > Delete the `let cfg = ...;` binding, the entire `options.* = ...;` declaration, and the `config = lib.mkIf cfg.enable {` wrapper plus its matching closing `}`. Keep `lib`/`config`/`pkgs`/`settings`/`palette` in the arg set ONLY if `BODY` still references them.

---

### Task 1: Capture the pre-flatten baseline

No source changes — record the current build output so later tasks can prove "no behavior change".

**Files:** none (writes baseline paths to `/tmp/flatten-baseline.txt`).

- [ ] **Step 1: Build both hosts' current toplevel and record store paths**

Run:
```bash
cd /etc/nixos
{ echo -n "rog-g14 "; nix build --no-link --print-out-paths \
    .#nixosConfigurations.rog-g14.config.system.build.toplevel
  echo -n "thinkpad-t14 "; nix build --no-link --print-out-paths \
    .#nixosConfigurations.thinkpad-t14.config.system.build.toplevel
} | tee /tmp/flatten-baseline.txt
```
Expected: two lines, each `<host> /nix/store/...-nixos-system-<host>-...`. Both builds succeed.

- [ ] **Step 2: Sanity-check nvd is runnable**

Run: `nix run nixpkgs#nvd -- --version`
Expected: prints an nvd version (downloads on first run). This is the diff tool used as the gate below.

---

### Task 2: De-option the system desktop modules; empty the system profile

Make every `modules/system/desktop/*` module plain. Core modules (`modules/system/core/*`) already have no options — leave them. Keep `lib/importAll.nix` and the current `flake.nix`/`mkHost.nix` in place; `modules/system/default.nix` still blanket-imports everything, so de-optioned modules apply unconditionally — same result as the profile enabling them. Remove each profile line as its module is de-optioned so the build never references a deleted option.

**Files:**
- Modify: `modules/system/desktop/{audio,bluetooth,graphics,portal,files,flatpak,inputmethod,hyprland,stylix}.nix`
- Modify: `profiles/system/hyprland.nix`

**Interfaces:**
- Produces: plain system modules (no `options.lunear.*`). `stylix.nix` now reads `settings.theme` directly instead of a `lunear.theme.name` option.

- [ ] **Step 1: De-option `audio.nix`**

Replace the whole file with:
```nix
{ ... }:

{
  # Real-time scheduling for PipeWire
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
```

- [ ] **Step 2: De-option `bluetooth.nix` (PRESERVE the A2DP block)**

Replace the whole file with:
```nix
{ ... }:

{
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  # Experimental = battery reporting + better codec negotiation.
  hardware.bluetooth.settings.General.Experimental = true;

  services.blueman.enable = true;

  # Default audio devices to A2DP. Without this a headset can land on the
  # "off"/HSP profile on connect -> connected but no sound.
  # HFP/HSP backend kept native so headset mic still works; we only stop the
  # automatic switch to the low-quality headset profile.
  services.pipewire.wireplumber.extraConfig."51-bluez-a2dp" = {
    "monitor.bluez.properties" = {
      "bluez5.roles" = [ "a2dp_sink" "a2dp_source" "hfp_hf" "hsp_hs" ];
      "bluez5.codecs" = [ "sbc" "sbc_xq" "aac" ];
      "bluez5.enable-sbc-xq" = true;
      "bluez5.hfphsp-backend" = "native";
      "bluez5.autoswitch-to-headset-profile" = false;
    };
  };
}
```

- [ ] **Step 3: De-option `graphics.nix`**

Replace the whole file with:
```nix
{ ... }:

{
  hardware.graphics.enable = true;
}
```

- [ ] **Step 4: De-option `portal.nix`**

Replace the whole file with:
```nix
{ pkgs, ... }:

{
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
```

- [ ] **Step 5: De-option `files.nix`**

Replace the whole file with:
```nix
{ ... }:

{
  services.udisks2.enable = true;
  services.gvfs.enable = true;
}
```

- [ ] **Step 6: De-option `flatpak.nix`**

Replace the whole file with:
```nix
{ ... }:

{
  services.flatpak = {
    enable = true;
    remotes = [{
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }];
  };
}
```

- [ ] **Step 7: De-option `inputmethod.nix`**

Replace the whole file with:
```nix
{ pkgs, ... }:

{
  # CJK glyphs for the candidate window (Noto Sans alone has no Han coverage).
  fonts.packages = [ pkgs.noto-fonts-cjk-sans ];

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-rime
        fcitx5-gtk
        qt6Packages.fcitx5-configtool
      ];
    };
  };
}
```

- [ ] **Step 8: De-option `hyprland.nix` (system)**

Replace the whole file with:
```nix
{ ... }:

{
  services.displayManager.gdm.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
}
```

- [ ] **Step 9: De-option `stylix.nix` (system) — read `settings.theme` directly**

Edit `modules/system/desktop/stylix.nix`:
1. Change the `let` block from
   ```nix
   let
     cfg = config.lunear.theme;
     themes = import ../../../themes { inherit pkgs; };
     theme = themes.${cfg.name};
   in
   ```
   to
   ```nix
   let
     themes = import ../../../themes { inherit pkgs; };
     theme = themes.${settings.theme};
   in
   ```
2. Delete the entire `options.lunear.theme = { ... };` block.
3. Change `config = lib.mkIf cfg.stylix.enable {` to `config = {` (keep the closing brace). The `stylix = lib.mkMerge [ ... ];` body is unchanged.
4. Ensure the arg set is `{ pkgs, lib, settings, ... }:` (drop `config` if now unused; `lib` is still used by `lib.mkMerge`/`lib.mkDefault`).

- [ ] **Step 10: Empty the system profile**

Replace `profiles/system/hyprland.nix` with:
```nix
{ ... }:

{
}
```

- [ ] **Step 11: Build rog-g14 and gate on nvd diff**

Run:
```bash
cd /etc/nixos
NEW=$(nix build --no-link --print-out-paths .#nixosConfigurations.rog-g14.config.system.build.toplevel)
OLD=$(awk '/^rog-g14 /{print $2}' /tmp/flatten-baseline.txt)
nix run nixpkgs#nvd -- diff "$OLD" "$NEW"
```
Expected: build succeeds; `nvd diff` reports `<<< ... >>> ...` headers and **no package add/remove/version lines** (closure identical). If anything differs, fix before continuing.

- [ ] **Step 12: Build thinkpad-t14 and gate on nvd diff**

Run:
```bash
cd /etc/nixos
NEW=$(nix build --no-link --print-out-paths .#nixosConfigurations.thinkpad-t14.config.system.build.toplevel)
OLD=$(awk '/^thinkpad-t14 /{print $2}' /tmp/flatten-baseline.txt)
nix run nixpkgs#nvd -- diff "$OLD" "$NEW"
```
Expected: identical closure (no diff lines).

- [ ] **Step 13: Commit**

```bash
cd /etc/nixos
git add modules/system/desktop profiles/system/hyprland.nix
git commit -m "refactor: de-option system desktop modules"
git log -1 --format='%an <%ae>%n%b'
```
Expected: commit author `Lunear01`, body has NO `Co-Authored-By`.

---

### Task 3: De-option home modules; remove app enums; fold app choices into the base profile

Make every home module plain, delete the `browser`/`terminal`/`editor` enum modules, and move their effects into `profiles/user/base.nix` (which becomes plain baseline config). `modules/user/default.nix` still blanket-imports, so de-optioned modules apply unconditionally — same result.

**Files:**
- Modify: `modules/user/shell/bash.nix`, `modules/user/dev/default.nix`, `modules/user/desktop/{kitty,waybar,swaync,hyprland,fcitx5}/default.nix`, `modules/user/desktop/stylix.nix`
- Delete: `modules/user/apps/browser/`, `modules/user/apps/terminal/`, `modules/user/apps/editor/`
- Modify: `profiles/user/base.nix`, `profiles/user/hyprland.nix`

**Interfaces:**
- Consumes: nothing new.
- Produces: plain home modules. App choices realized as: kitty (module imported), vscode (dev module) + `home.sessionVariables.EDITOR = "code --wait"`, zen (`services.flatpak.packages = [ "app.zen_browser.zen" ]`). All three live in `profiles/user/base.nix` for now (moved to `common-home.nix` in Task 4).

- [ ] **Step 1: De-option `bash.nix`**

Replace the whole file with:
```nix
{ settings, ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      nrs = "sudo nixos-rebuild --flake /etc/nixos#${settings.hostname} switch";
      btw = "echo i use nix btw";
      die = "poweroff";
    };
  };
}
```

- [ ] **Step 2: De-option `dev/default.nix`**

Replace the whole file with:
```nix
{ pkgs, ... }:

{
  programs.git.enable = true;
  programs.vscode = {
    enable = true;
    profiles.default.userSettings = {
      "terminal.integrated.gpuAcceleration" = "off";
      "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font Mono";
    };
  };

  home.packages = with pkgs; [
    claude-code
    nodejs_22
    gh
    python3
  ];
}
```

- [ ] **Step 3: De-option `kitty/default.nix`**

In `modules/user/desktop/kitty/default.nix`: change the arg set to `{ config, ... }:`, delete `cfg = config.lunear.home.kitty;` from the `let` (keep `home = config.home.homeDirectory;`), delete the `options.lunear.home.kitty.enable = ...;` line, and change `config = lib.mkIf cfg.enable {` to just open the attrset directly (remove the wrapper and its matching closing brace). Result:
```nix
{ config, ... }:

let
  home = config.home.homeDirectory;
in
{
  stylix.opacity.terminal = 0.80;

  programs.kitty = {
    enable = true;
    extraConfig = ''
      dynamic_background_opacity yes
      startup_session ${home}/.config/kitty/session.conf
    '';
  };

  xdg.configFile."kitty/session.conf".source = ./dotfiles/session.conf;
}
```

- [ ] **Step 4: De-option `waybar/default.nix`**

In `modules/user/desktop/waybar/default.nix`: arg set becomes `{ pkgs, palette, settings, ... }:`. Delete `cfg = config.lunear.home.waybar;` from the `let` (keep `styleCss` and `colorsCss`). Delete the `options.lunear.home.waybar.enable = ...;` line. Change `config = lib.mkIf cfg.enable {` to open the attrset directly and remove its matching closing brace. The body (`programs.waybar`, `systemd.user.services.waybar`, `xdg.configFile`) is unchanged.

- [ ] **Step 5: De-option `swaync/default.nix`**

In `modules/user/desktop/swaync/default.nix`: arg set becomes `{ pkgs, palette, config, ... }:` (`config` still used by `config.lib.stylix.colors`). Delete `cfg = config.lunear.home.swaync;` from the `let`. Delete the `options.lunear.home.swaync.enable = ...;` line. Change `config = lib.mkIf cfg.enable {` to open the attrset directly and remove its matching closing brace. Body unchanged.

- [ ] **Step 6: De-option `hyprland/default.nix` (home)**

In `modules/user/desktop/hyprland/default.nix`: arg set becomes `{ pkgs, paletteRaw, settings, ... }:`. Delete `cfg = config.lunear.home.hyprland;` from the `let` (keep `hostLua` and `colorsLua`). Delete the `options.lunear.home.hyprland.enable = ...;` line. Change `config = lib.mkIf cfg.enable {` to open the attrset directly and remove its matching closing brace. Body (`services.cliphist`, `services.playerctld`, `home.packages`, `systemd.user.targets`, `xdg.configFile`) unchanged.

- [ ] **Step 7: De-option `fcitx5/default.nix`**

In `modules/user/desktop/fcitx5/default.nix`: arg set becomes `{ pkgs, palette, config, ... }:` (`config` still used by `config.stylix.fonts...`). Delete `cfg = config.lunear.home.fcitx5;` from the `let` (keep all the theme-building bindings). Delete the `options.lunear.home.fcitx5.enable = ...;` line. Change `config = lib.mkIf cfg.enable {` to open the attrset directly and remove its matching closing brace. Body (`xdg.dataFile`, `xdg.configFile`) unchanged.

- [ ] **Step 8: De-option `modules/user/desktop/stylix.nix` (stylix targets)**

Replace the whole file with:
```nix
{ ... }:

{
  stylix.targets = {
    waybar.enable = false;
    rofi.enable = false;
    hyprland.enable = false;
    swaync.enable = false;
    firefox.profileNames = [ "default" ];
  };
}
```

- [ ] **Step 9: De-option `rofi/default.nix`**

In `modules/user/desktop/rofi/default.nix`: arg set becomes `{ pkgs, palette, themed, settings, config, ... }:` (`config` still used by `config.lib.stylix.colors`). Delete `cfg = config.lunear.home.rofi;` from the `let` (keep `themeRasi`, `base01`, `colorsRasi`). Delete the `options.lunear.home.rofi.enable = ...;` line. Change `config = lib.mkIf cfg.enable {` to open the attrset directly and remove its matching closing brace. Body (`programs.rofi`, `xdg.configFile`) unchanged.

- [ ] **Step 10: Delete the enum app modules**

Run:
```bash
cd /etc/nixos
git rm -r modules/user/apps
```
Expected: removes `browser/`, `terminal/`, `editor/`.

- [ ] **Step 11: Rewrite `profiles/user/base.nix` as plain baseline (absorb the app choices)**

Replace the whole file with:
```nix
{ pkgs, ... }:

{
  programs.fastfetch.enable = true;
  fonts.fontconfig.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  # Editor: VSCode (program enabled in the dev module).
  home.sessionVariables.EDITOR = "code --wait";

  # Browser: Zen, shipped as a Flathub flatpak (remote declared in home.nix).
  services.flatpak.packages = [ "app.zen_browser.zen" ];

  home.packages = with pkgs; [
    # CLI utilities
    tree
    wget

    # Browser web-app host (PWA host; primary browser is Zen above)
    chromium

    # VPN / networking
    wireguard-tools
    proton-vpn

    # Fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    noto-fonts
  ];
}
```

- [ ] **Step 12: Empty the user hyprland profile**

Replace `profiles/user/hyprland.nix` with:
```nix
{ ... }:

{
}
```

- [ ] **Step 13: Build both hosts and gate on nvd diff**

Run:
```bash
cd /etc/nixos
for h in rog-g14 thinkpad-t14; do
  NEW=$(nix build --no-link --print-out-paths .#nixosConfigurations.$h.config.system.build.toplevel)
  OLD=$(awk -v H=$h '$1==H{print $2}' /tmp/flatten-baseline.txt)
  echo "=== $h ==="; nix run nixpkgs#nvd -- diff "$OLD" "$NEW"
done
```
Expected: both build; both diffs show no package changes. (EDITOR moving from the editor enum to base, and zen/kitty now applying via direct import rather than enum, produce the same closure.)

- [ ] **Step 14: Commit**

```bash
cd /etc/nixos
git add -A
git commit -m "refactor: de-option home modules, remove app enums"
git log -1 --format='%an <%ae>%n%b'
```
Expected: author `Lunear01`, no co-author trailer.

---

### Task 4: Restructure to the flat target layout

Pure mechanical reorg now that all modules are plain. Introduce explicit `flake.nix`, a trivial `mkHost`, the two `common-*.nix` baselines, flatten the module directories, and delete the dead plumbing.

**Files:**
- Rewrite: `flake.nix`, `lib/mkHost.nix`
- Create: `common-system.nix`, `common-home.nix`
- Move: `modules/system/core/*` and `modules/system/desktop/*` → `modules/system/*`; `modules/user/*` → `modules/home/*` (with `lib.nix`→`palette.nix`, `desktop/stylix.nix`→`stylix-targets.nix`)
- Rename: `hosts/<h>/default.nix` → `hosts/<h>/configuration.nix`; rewrite `hosts/<h>/home.nix`
- Create: `users/lunear.nix`; Delete: `users/lunear/`
- Delete: `lib/importAll.nix`, `modules/system/default.nix`, `modules/user/default.nix`, `profiles/`
- Modify: `vars.nix`, `hosts/<h>/vars.nix` (unchanged content, confirm)

**Interfaces:**
- Consumes: plain modules from Tasks 2–3.
- Produces: `mkHost { hostname, settings }` factory; `settings` carries `hostname` (injected by mkHost). Home modules receive `settings` via `extraSpecialArgs`; `palette`/`paletteRaw`/`themed` via `modules/home/palette.nix` `_module.args`.

- [ ] **Step 1: Flatten the system module directory**

Run:
```bash
cd /etc/nixos
git mv modules/system/core/boot.nix       modules/system/boot.nix
git mv modules/system/core/locale.nix     modules/system/locale.nix
git mv modules/system/core/networking.nix modules/system/networking.nix
git mv modules/system/core/nix.nix        modules/system/nix.nix
git mv modules/system/core/nix-ld.nix     modules/system/nix-ld.nix
git mv modules/system/core/security.nix   modules/system/security.nix
git mv modules/system/desktop/audio.nix       modules/system/audio.nix
git mv modules/system/desktop/bluetooth.nix   modules/system/bluetooth.nix
git mv modules/system/desktop/graphics.nix    modules/system/graphics.nix
git mv modules/system/desktop/portal.nix      modules/system/portal.nix
git mv modules/system/desktop/files.nix       modules/system/files.nix
git mv modules/system/desktop/flatpak.nix     modules/system/flatpak.nix
git mv modules/system/desktop/inputmethod.nix modules/system/inputmethod.nix
git mv modules/system/desktop/hyprland.nix    modules/system/hyprland.nix
git mv modules/system/desktop/stylix.nix      modules/system/stylix.nix
git rm modules/system/default.nix
rmdir modules/system/core modules/system/desktop
```

- [ ] **Step 2: Fix the relative path in `modules/system/stylix.nix`**

The file moved up one level, so the themes import path changes. Edit `modules/system/stylix.nix`: change `import ../../../themes` to `import ../../themes`.

- [ ] **Step 3: Flatten the home module directory**

Run:
```bash
cd /etc/nixos
git mv modules/user/lib.nix            modules/home/palette.nix
git mv modules/user/shell/bash.nix     modules/home/bash.nix
git mv modules/user/dev/default.nix    modules/home/dev.nix
git mv modules/user/desktop/stylix.nix modules/home/stylix-targets.nix
git mv modules/user/desktop/kitty      modules/home/kitty
git mv modules/user/desktop/waybar     modules/home/waybar
git mv modules/user/desktop/swaync     modules/home/swaync
git mv modules/user/desktop/hyprland   modules/home/hyprland
git mv modules/user/desktop/rofi       modules/home/rofi
git mv modules/user/desktop/fcitx5     modules/home/fcitx5
git rm modules/user/default.nix
rmdir modules/user/shell modules/user/dev modules/user/desktop modules/user
```
(The `kitty/`, `waybar/`, etc. dirs keep their `default.nix` + `dotfiles/` — no internal path changes needed; they use `./dotfiles/...` relative paths.)

- [ ] **Step 4: Create `common-system.nix`**

Create `/etc/nixos/common-system.nix`:
```nix
# Shared system baseline imported by every host's configuration.nix.
# Every module here applies unconditionally — to stop using one, remove its
# import line.
{ ... }:

{
  imports = [
    ./modules/system/boot.nix
    ./modules/system/locale.nix
    ./modules/system/networking.nix
    ./modules/system/nix.nix
    ./modules/system/nix-ld.nix
    ./modules/system/security.nix
    ./modules/system/audio.nix
    ./modules/system/bluetooth.nix
    ./modules/system/graphics.nix
    ./modules/system/portal.nix
    ./modules/system/files.nix
    ./modules/system/flatpak.nix
    ./modules/system/inputmethod.nix
    ./modules/system/hyprland.nix
    ./modules/system/stylix.nix
  ];
}
```

- [ ] **Step 5: Create `common-home.nix`**

Create `/etc/nixos/common-home.nix`:
```nix
# Shared home (home-manager) baseline imported by every host's home.nix.
# Every module here applies unconditionally — to stop using one, remove its
# import line. `settings` is an extraSpecialArg (see lib/mkHost.nix);
# palette/paletteRaw/themed come from ./modules/home/palette.nix.
{ pkgs, settings, ... }:

{
  imports = [
    ./modules/home/palette.nix
    ./modules/home/bash.nix
    ./modules/home/dev.nix
    ./modules/home/stylix-targets.nix
    ./modules/home/kitty
    ./modules/home/waybar
    ./modules/home/swaync
    ./modules/home/hyprland
    ./modules/home/rofi
    ./modules/home/fcitx5
  ];

  home.username = settings.username;
  home.homeDirectory = "/home/${settings.username}";
  home.stateVersion = "26.05";

  programs.fastfetch.enable = true;
  fonts.fontconfig.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  # Editor: VSCode (program enabled in dev.nix).
  home.sessionVariables.EDITOR = "code --wait";

  # Flatpak remote + Zen browser (system flatpak service is in the system module).
  services.flatpak.remotes = [{
    name = "flathub";
    location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
  }];
  services.flatpak.packages = [ "app.zen_browser.zen" ];

  home.packages = with pkgs; [
    tree
    wget
    chromium
    wireguard-tools
    proton-vpn
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    noto-fonts
  ];
}
```

- [ ] **Step 6: Create `users/lunear.nix` and delete the old user dir**

Create `/etc/nixos/users/lunear.nix`:
```nix
{ ... }:

{
  users.users.lunear = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };
}
```
Then:
```bash
cd /etc/nixos
git rm -r users/lunear
```

- [ ] **Step 7: Rename + rewrite the host `configuration.nix` files**

```bash
cd /etc/nixos
git mv hosts/rog-g14/default.nix      hosts/rog-g14/configuration.nix
git mv hosts/thinkpad-t14/default.nix hosts/thinkpad-t14/configuration.nix
```
Then set `hosts/rog-g14/configuration.nix` to:
```nix
{ pkgs, ... }:

{
  imports = [
    ../../common-system.nix
    ./hardware-configuration.nix
  ];

  # ROG G14-specific: asusd (fan curves, keyboard LEDs, power profiles).
  services.asusd.enable = true;

  environment.systemPackages = with pkgs; [
    # asusctl
  ];

  system.stateVersion = "26.05";
}
```
And set `hosts/thinkpad-t14/configuration.nix` to mirror the current T14 default (replace its `imports` line `../../profiles/system/hyprland.nix` with `../../common-system.nix`, keep its existing host-specific bits and `system.stateVersion`). Read the file first and preserve every host-only setting; only the imports line changes.

- [ ] **Step 8: Rewrite the host `home.nix` files to import the home baseline**

Set `hosts/rog-g14/home.nix` to:
```nix
# ROG G14 home: shared baseline + host-only user packages.
{ pkgs, ... }:

{
  imports = [ ../../common-home.nix ];

  home.packages = with pkgs; [
    # Gaming / GPU-box extras, e.g. mangohud, lutris
  ];
}
```
Set `hosts/thinkpad-t14/home.nix` to:
```nix
# ThinkPad T14 home: shared baseline + host-only user packages.
{ pkgs, ... }:

{
  imports = [ ../../common-home.nix ];

  home.packages = with pkgs; [
  ];
}
```
(If the current T14 `home.nix` already lists host-only packages, preserve them inside the list.)

- [ ] **Step 9: Rewrite `lib/mkHost.nix` (trivial factory)**

Replace `lib/mkHost.nix` with:
```nix
# nixosSystem factory. Takes a hostname and the merged settings; injects
# `hostname` into settings, threads `settings` to every module (system as a
# specialArg, home via extraSpecialArgs), and wires home-manager for the one
# user. flake.nix lists hosts explicitly and does the vars merge.
{ inputs }:

{ hostname, settings }:

let
  lib = inputs.nixpkgs.lib;
  settings' = settings // { inherit hostname; };
in
lib.nixosSystem {
  system = settings'.system;
  specialArgs = { inherit inputs; settings = settings'; };
  modules = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.stylix.nixosModules.stylix
    ../users/lunear.nix
    ../hosts/${hostname}/configuration.nix
    inputs.home-manager.nixosModules.home-manager
    {
      networking.hostName = hostname;
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        extraSpecialArgs = { inherit inputs; settings = settings'; };
        sharedModules = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];
        users.${settings'.username}.imports = [ ../hosts/${hostname}/home.nix ];
      };
      nix.registry.nixpkgs.flake = inputs.nixpkgs;
      nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    }
  ];
}
```

- [ ] **Step 10: Rewrite `flake.nix` (explicit hosts + vars merge)**

Replace `flake.nix` with:
```nix
{
  description = "Lunear's NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      mkHost = import ./lib/mkHost.nix { inherit inputs; };
      shared = import ./vars.nix;
    in {
      nixosConfigurations = {
        rog-g14 = mkHost {
          hostname = "rog-g14";
          settings = shared // import ./hosts/rog-g14/vars.nix;
        };
        thinkpad-t14 = mkHost {
          hostname = "thinkpad-t14";
          settings = shared // import ./hosts/thinkpad-t14/vars.nix;
        };
      };
    };
}
```

- [ ] **Step 11: Prune unused fields from `vars.nix`**

Edit `vars.nix`: delete the `browser`, `terminal`, and `editor` lines (no longer read by anything). Keep `system`, `users`, `theme`, `username`, `monitor`, `scale`, `cursorSize`, `barFontPx`, `rofiFontPt`. (`users` may stay for documentation even though mkHost no longer reads it; leaving it is harmless. If removed, confirm nothing references `settings.users`.)

- [ ] **Step 12: Delete the dead plumbing**

```bash
cd /etc/nixos
git rm lib/importAll.nix
git rm -r profiles
```

- [ ] **Step 13: Build both hosts and gate on nvd diff**

Run:
```bash
cd /etc/nixos
nix flake check 2>&1 | tail -5
for h in rog-g14 thinkpad-t14; do
  NEW=$(nix build --no-link --print-out-paths .#nixosConfigurations.$h.config.system.build.toplevel)
  OLD=$(awk -v H=$h '$1==H{print $2}' /tmp/flatten-baseline.txt)
  echo "=== $h ==="; nix run nixpkgs#nvd -- diff "$OLD" "$NEW"
done
```
Expected: `nix flake check` passes; both hosts build; both `nvd diff` show no package changes (identical closure to baseline).

- [ ] **Step 14: Commit**

```bash
cd /etc/nixos
git add -A
git commit -m "refactor: flatten config to explicit modules + common baselines"
git log -1 --format='%an <%ae>%n%b'
```
Expected: author `Lunear01`, no co-author trailer.

---

### Task 5: Final verification, activation, and docs

**Files:**
- Modify: `README.md`, `ROADMAP.md`

- [ ] **Step 1: Confirm the dead abstractions are gone**

Run:
```bash
cd /etc/nixos
echo "lunear options:"; grep -rn "mkEnableOption\|options.lunear\|config.lunear" --include=*.nix . || echo "  none"
echo "importAll refs:"; grep -rn "importAll" --include=*.nix . || echo "  none"
ls profiles 2>/dev/null && echo "PROFILES STILL EXIST" || echo "profiles: gone"
ls modules/user 2>/dev/null && echo "modules/user STILL EXISTS" || echo "modules/user: gone"
```
Expected: no `lunear` option references, no `importAll`, `profiles` gone, `modules/user` gone. (Any `lunear` hits should only be in comments/strings — inspect and clear if so.)

- [ ] **Step 2: Activate on the current host (rog-g14)**

> This is the only irreversible step and needs sudo + the user present. Confirm the Task 4 `nvd diff` was clean before running.

Run:
```bash
cd /etc/nixos
sudo nixos-rebuild switch --flake .#rog-g14
```
Expected: builds and activates without error. Verify the desktop is intact (bar, launcher, theme) and bluetooth audio still works.

- [ ] **Step 3: Update `README.md`**

Rewrite `README.md` to describe the new flat layout: `flake.nix` (lists hosts), `vars.nix` (shared settings), `common-system.nix` / `common-home.nix` (shared baselines), `modules/system/` + `modules/home/` (plain modules — importing one enables it), `hosts/<name>/`, `themes/`, `users/lunear.nix`. Include a "How do I…" section: *add a module* (create file, add one import line to the relevant `common-*.nix`), *change the theme* (edit `theme` in `vars.nix`), *tune a host's display* (edit `hosts/<name>/vars.nix`).

- [ ] **Step 4: Update `ROADMAP.md`**

Append to `ROADMAP.md` change log: the config was flattened (removed `lunear.*` options, `profiles/`, `lib/importAll.nix`, app enums; added `common-system.nix`/`common-home.nix`; flattened `modules/`). Check off any related TODO.

- [ ] **Step 5: Commit the docs**

```bash
cd /etc/nixos
git add README.md ROADMAP.md
git commit -m "docs: document the flattened config layout"
git log -1 --format='%an <%ae>%n%b'
```
Expected: author `Lunear01`, no co-author trailer.

- [ ] **Step 6: Merge to main (optional, user-gated)**

When the user confirms the system has run cleanly for a bit:
```bash
cd /etc/nixos
git checkout main && git merge --no-ff config-flatten
```
(Leave on `config-flatten` until the user asks to merge.)

---

## Notes on the nvd-diff gate

`nvd diff <old> <new>` compares two system closures. A clean result has the
`<<<`/`>>>` path headers but **no `[U.]`/`[C.]`/`[A.]`/`[R.]` package lines** —
meaning nothing was added, removed, or version-changed. That is the proof this
refactor changed structure only, not the built system. If a diff is non-empty,
the most likely causes are: a module that stopped being imported (missing line in
a `common-*.nix`), an arg dropped that the body still uses, or a relative path
not updated after a `git mv`.
