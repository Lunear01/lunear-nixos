# Shared desktop policy: the generic pieces any graphical session wants,
# independent of which compositor/DE sits on top.
{ ... }:

{
  lunear.desktop.audio.enable = true;
  lunear.desktop.bluetooth.enable = true;
  lunear.desktop.graphics.enable = true;
  lunear.desktop.portal.enable = true;
  lunear.desktop.files.enable = true;
  lunear.services.flatpak.enable = true;
}
