# Claude Code profile: Optional Claude AI coding assistant
{
  config,
  pkgs,
  lib,
  ...
}: {
  # --- Custom Options ---
  options.vibe-station.claude-code = {
    enable = lib.mkEnableOption "Enable the Claude Code assistant";
  };

  # --- Configuration ---
  config = lib.mkIf config.vibe-station.claude-code.enable {
    # --- Claude Code Setup ---
    home.packages = with pkgs; [
      nodejs_22
    ];

    # Create a local bin directory for user-installed packages
    home.file.".local/bin/.keep".text = "";

    # Add npm config to use a local prefix for global packages
    home.file.".npmrc".text = ''
      prefix=$HOME/.local
    '';

    # Add Claude Code installation script
    home.file.".local/bin/install-claude-code" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        # Ensure local bin directory exists
        mkdir -p $HOME/.local/bin

        echo "Installing Claude Code..."
        # Use npm to install Claude Code to the user's local directory
        PATH="$PATH:${pkgs.nodejs_22}/bin" npm install -g @anthropic-ai/claude-code

        echo "Claude Code installed successfully!"
        echo "You can now run 'claude-code' from your terminal."
      '';
    };

    # Add Claude Code documentation
    home.file.".local/share/doc/claude-code/README.md".text = ''
      # Claude Code in Vibe Station

      Claude Code is an AI assistant developed by Anthropic to help with software development tasks.

      ## Installation

      Claude Code is not installed by default to keep the environment clean.
      To install Claude Code, run:

      ```bash
      install-claude-code
      ```

      This will install Claude Code into your user's local bin directory.

      ## Usage

      After installation, you can use Claude Code by running:

      ```bash
      claude-code
      ```

      For more information, visit the [Claude Code documentation](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview).

      ## Configuration

      If you need to authenticate with Claude Code, follow the instructions provided in the CLI.
      Your authentication tokens will be stored in your user profile and won't affect the Vibe Station repository.
    '';

    # Update PATH to include the local bin directory
    programs.zsh.initExtra = lib.mkAfter ''
      # Add local bin to PATH for Claude Code
      export PATH="$HOME/.local/bin:$PATH"

      # Add Claude Code completion if it exists
      if [ -f "$HOME/.local/bin/claude-code" ]; then
        # Check if claude-code supports completion
        if $HOME/.local/bin/claude-code --help | grep -q "completion"; then
          # Generate completion script and source it
          source <($HOME/.local/bin/claude-code completion)
        fi
      fi
    '';
  };
}
