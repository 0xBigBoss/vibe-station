# Vibe Station Bin Directory

This document describes the vibe-station bin directory feature, which provides a convenient way to install and access executable scripts and tools in your vibe-station environment.

## Overview

The vibe-station bin directory (`~/.vibe-station/bin`) is a special directory that:

1. Is automatically created in your home directory (`/home/coder/.vibe-station/bin`)
2. Is automatically added to your `PATH` environment variable
3. Contains useful scripts and tools specific to the vibe-station environment
4. Persists across container restarts

This feature allows you to easily access useful scripts and tools from anywhere in the container without needing to specify the full path.

## Default Scripts

The vibe-station bin directory comes with several pre-installed scripts:

1. **claude** - A wrapper script for Claude Code CLI that allows you to launch an AI coding assistant:
   ```bash
   # Execute the Claude Code assistant
   claude
   
   # Pass arguments directly to Claude Code
   claude --help
   ```

## How It Works

The bin directory is configured through Home Manager in the `nix/home-manager/profiles/base.nix` file:

```nix
# --- Vibe Station Bin Directory ---
# Create a bin directory for vibe station scripts and executables
home.sessionPath = [ "$HOME/.vibe-station/bin" ];

# Ensure the ~/.vibe-station/bin directory exists
home.file.".vibe-station/bin/.keep".text = "";

# Create the claude script directly in the home directory
home.file.".vibe-station/bin/claude" = {
  text = ''
    #!/usr/bin/env nix-shell
    #! nix-shell -p nodejs_22 -i sh
    # shellcheck shell=sh
    npx @anthropic-ai/claude-code "$@"
  '';
  executable = true;
};
```

This configuration:
1. Adds `~/.vibe-station/bin` to the `PATH` environment variable using `home.sessionPath`
2. Creates the bin directory if it doesn't exist
3. Installs the `claude` script in the bin directory and makes it executable

## Adding Your Own Scripts via Home Manager

The recommended way to add scripts to the vibe-station bin directory is through Home Manager:

1. Edit the `nix/home-manager/profiles/base.nix` file
2. Add a new entry under the `home.file` section:

```nix
# Add your custom script
home.file.".vibe-station/bin/my-script" = {
  text = ''
    #!/bin/sh
    # Your script content here
    echo "Hello from my custom script!"
  '';
  executable = true;
};
```

3. Apply the changes with home-manager:
```bash
cd /app/nix/home-manager && home-manager switch --flake .#coder
```

## Best Practices

1. **Keep scripts simple and focused**: Each script should do one thing well
2. **Add proper shebang lines**: Always include `#!/bin/sh` or appropriate interpreter at the beginning
3. **Add documentation**: Include comments at the top of your scripts explaining their purpose and usage
4. **Use environment variables**: Avoid hardcoding paths when possible

## Troubleshooting

If your scripts in the bin directory are not accessible:

1. Verify the bin directory is in your PATH:
```bash
echo $PATH | grep ".vibe-station/bin"
```

2. Check if your Home Manager configuration has been applied:
```bash
cd /app/nix/home-manager && home-manager switch --flake .#coder
```

3. Check the session variables file to confirm PATH updates:
```bash
cat ~/.nix-profile/etc/profile.d/hm-session-vars.sh
```