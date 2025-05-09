{ pkgs, ... }:

{
  home.username      = "topi";
  home.homeDirectory = "/home/topi";

  home.stateVersion  = "24.11";        # DO NOT touch on upgrades

  home.packages = with pkgs; [
    brave mullvad-browser
  ];

  xdg.enable = true;                   # creates ~/.config, ~/.local/share …
}
