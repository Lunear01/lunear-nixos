# Per-user settings: the single source of truth for this user. Threaded to every
# home module as the `userSettings` arg (via _module.args in lib/mkHost.nix).
# Enum fields drive the choice-based app modules (browser/terminal/editor).
{
  username = "lunear";
  browser = "firefox";
  terminal = "kitty";
  editor = "vim";
  theme = "everforest-dark-hard";
}
