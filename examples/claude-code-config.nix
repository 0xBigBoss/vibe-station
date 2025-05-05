# Example configuration to enable Claude Code in your Vibe Station
{ config, lib, pkgs, ... }: {
  # Enable the Claude Code extension
  vibe-station.claude-code.enable = true;
  
  # Any additional personal configuration can go here
  # For example:
  # home.packages = with pkgs; [
  #   your-favorite-package
  # ];
}