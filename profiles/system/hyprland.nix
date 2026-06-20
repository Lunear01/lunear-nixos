# Hyprland desktop policy: the shared graphical baseline (audio, bluetooth,
# graphics, portal, files, flatpak) plus the Hyprland compositor and Stylix.
{ ... }:

{
  # Generic graphical baseline (compositor-independent). Split this back out into
  # its own profile if a second compositor/DE ever needs to share it.
  lunear.desktop.audio.enable = true;
  lunear.desktop.bluetooth.enable = true;
  lunear.desktop.graphics.enable = true;
  lunear.desktop.portal.enable = true;
  lunear.desktop.files.enable = true;
  lunear.services.flatpak.enable = true;

  # Hyprland compositor + theming.
  lunear.desktop.hyprland.enable = true;
  lunear.theme.stylix.enable = true;
}
