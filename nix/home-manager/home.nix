# Main Home Manager configuration for Vibe Station
{
  config,
  pkgs,
  lib,
  ...
}: {
  # Import the profile layers
  imports = [
    ./profiles/base.nix
    ./profiles/personal.nix
    # Claude Code profile is available but not imported by default
    # Users can enable it with a custom configuration file
    # Add other profiles like ./profiles/work.nix here if needed
  ];

  # --- Core Home Manager Settings ---
  # !! IMPORTANT: Customize these values !!
  home.username = "coder"; # Username for Docker container
  home.homeDirectory = "/home/coder"; # Home directory path for Docker container

  # Nicely reload systemd units when changing configs.
  systemd.user.startServices = "sd-switch";

  # Basic state version - update this periodically after running `home-manager switch`
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when receiving updates.
  # Before changing this value read the Home Manager release notes.
  home.stateVersion = "25.05"; # Or the version you intend to track

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # --- User Preferences & Settings ---
  # Example: Set preferred editor
  # programs.neovim.enable = true; # Uncomment and configure if you use Neovim
  # programs.vscode = {
  #   enable = true;
  #   # Add extensions or settings here
  # };

  # Add other global configurations here if they don't fit neatly into a profile.
}
