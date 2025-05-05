# Claude Code Extension for Vibe Station

Claude Code is an AI-powered coding assistant developed by Anthropic that helps with software development tasks. This extension allows you to optionally add Claude Code to your Vibe Station environment without affecting the base configuration.

## Enabling Claude Code

To add Claude Code to your Vibe Station:

1. Create a custom configuration file in your mounted directory (this will not modify the repository):

```bash
# Create a file in your host machine's mounted directory
cat > claude-code-config.nix << 'EOF'
{ config, lib, pkgs, ... }: {
  # Enable Claude Code
  vibe-station.claude-code.enable = true;
}
EOF
```

2. Apply this custom configuration with Home Manager:

```bash
# Run Home Manager with your custom configuration
docker compose exec code-server bash -c "cd /app/.vibe-station/nix/home-manager && home-manager switch --flake .#coder -I custom-config=/app/mount/claude-code-config.nix" > home-manager-switch.log 2>&1
```

This approach keeps the Claude Code configuration entirely in your mounted directory, ensuring it doesn't affect the Vibe Station repository.

## Installing Claude Code

After enabling the Claude Code extension, you need to install it:

```bash
# Run the installation script
install-claude-code
```

This script will install Claude Code in your user's local directory (`~/.local/bin`), making it available in your PATH without modifying the system-wide configuration.

## Using Claude Code

Once installed, you can run Claude Code with:

```bash
claude-code
```

For more detailed usage instructions, refer to the [official Claude Code documentation](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview).

## Authentication

When you first run Claude Code, you'll be prompted to authenticate. Your authentication tokens will be stored in your user profile and won't affect the Vibe Station repository.

## Data Persistence

Claude Code settings are stored in your home directory, which is preserved across container restarts using Docker volumes. This means your authentication and preferences will persist even if you restart the Vibe Station container.

## Troubleshooting

If you encounter permission issues or other problems with Claude Code:

1. Make sure you have enabled the extension with the custom configuration file
2. Check that the installation script completed successfully
3. Verify that `~/.local/bin` is in your PATH by running `echo $PATH`
4. Try reinstalling with `install-claude-code`

## Updating Claude Code

To update Claude Code to the latest version:

```bash
install-claude-code
```

This will reinstall Claude Code with the latest version.