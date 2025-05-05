#!/bin/bash
set -euo pipefail

COMPOSE_PATH="/Users/allen/0xbigboss/0xsend/sendapp-vibe-station/.vibe-station/compose.yml"
DOCKER_CMD="docker compose -f $COMPOSE_PATH"

echo "===== TESTING CLAUDE CODE EXTENSION ====="

# Cleanup any previous test files first
echo "0. Cleaning up previous test files..."
$DOCKER_CMD exec -T code-server bash -c "rm -f /tmp/test-claude-code.nix || true"

echo "1. Creating the test configuration..."
cat > /tmp/test-claude-module.nix << 'EOL'
{ config, lib, pkgs, ... }: {
  # Define the options
  options.vibe-station.claude-code = {
    enable = lib.mkEnableOption "Enable the Claude Code assistant";
  };

  # Enable the feature
  config = lib.mkIf true {
    # Put nodejs in the environment
    home.packages = with pkgs; [ nodejs_22 ];
    
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
      # Claude Code in Vibe Station - Test Installation

      This is a test installation of Claude Code.
    '';

    # Add PATH to include the local bin directory
    home.sessionVariables = {
      PATH = "$HOME/.local/bin:$PATH";
    };
  };
}
EOL

$DOCKER_CMD cp /tmp/test-claude-module.nix code-server:/tmp/test-claude-code.nix

echo "2. Running home-manager switch with the test configuration..."
$DOCKER_CMD exec -T code-server bash -c "cd /app/.vibe-station/nix/home-manager && \
  timeout 300 home-manager switch --flake .#coder -I claudeCode=/tmp/test-claude-code.nix" > home-manager-test.log 2>&1

echo "3. Testing if the install-claude-code script was created..."
$DOCKER_CMD exec -T code-server bash -c "ls -la /home/coder/.local/bin/install-claude-code || echo 'Script not found'"

echo "4. Testing if the script is executable..."
$DOCKER_CMD exec -T code-server bash -c "if [ -f /home/coder/.local/bin/install-claude-code ]; then \
  test -x /home/coder/.local/bin/install-claude-code && echo 'Script is executable' || echo 'Script is NOT executable'; \
else \
  echo 'Script file not found'; \
fi"

echo "5. Checking script content (if exists)..."
$DOCKER_CMD exec -T code-server bash -c "if [ -f /home/coder/.local/bin/install-claude-code ]; then \
  head -5 /home/coder/.local/bin/install-claude-code || echo 'Cannot read script'; \
else \
  echo 'Script file not found'; \
fi"

echo "6. Testing npm configuration..."
$DOCKER_CMD exec -T code-server bash -c "if [ -f /home/coder/.npmrc ]; then \
  cat /home/coder/.npmrc || echo 'Cannot read .npmrc'; \
else \
  echo '.npmrc file not found'; \
fi"

echo "7. Testing docs installation..."
$DOCKER_CMD exec -T code-server bash -c "if [ -f /home/coder/.local/share/doc/claude-code/README.md ]; then \
  cat /home/coder/.local/share/doc/claude-code/README.md || echo 'Cannot read README.md'; \
else \
  echo 'README.md file not found'; \
fi"

echo "===== TEST COMPLETED ====="