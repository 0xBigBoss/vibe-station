# Standalone Installation of Vibe Station

This guide provides detailed instructions for using Vibe Station as a Nix flake template that can be easily integrated with home-manager or used standalone without requiring tight VCS integration with your projects.

## Overview

The flake template approach allows you to:

1. Use Vibe Station as a template for new projects
2. Include it in your home-manager configuration
3. Clone and use it directly
4. Maintain a consistent development environment across all your projects

## Prerequisites

1. **Nix**: Ensure you have Nix installed with support for the experimental `nix command` and `flakes` features. This is typically done by adding the following to your Nix configuration (`/etc/nix/nix.conf` or `~/.config/nix/nix.conf`):
   ```
   experimental-features = nix-command flakes
   ```

2. **code-server**: The Vibe Station flake includes code-server, but you'll need to run it yourself.

3. **Docker** (Optional): If you want to run in a containerized environment, ensure Docker and Docker Compose are installed and running on your system.

## Usage Options

### Option 1: Use as a Flake Template

You can use Vibe Station as a template for new projects:

```bash
# Create a new project using the template
mkdir my-vibe-station
cd my-vibe-station
nix flake init -t github:username/vibe-station
```

This will create a new project with the Vibe Station flake configuration.

### Option 2: Include in Home Manager

You can include Vibe Station in your home-manager configuration:

```nix
# In your home-manager configuration
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    vibe-station.url = "github:username/vibe-station";
  };

  outputs = { nixpkgs, home-manager, vibe-station, ... }: {
    homeConfigurations."yourusername" = home-manager.lib.homeManagerConfiguration {
      # ...
      modules = [
        {
          # Add vibe-station to your packages
          home.packages = [ vibe-station.packages.${system}.code-server ];
          # Or use it in your shell configuration
          programs.bash.initExtra = ''
            # Add vibe-station shell hook
            if [ -f ${vibe-station}/bin/vibe-station-hook ]; then
              source ${vibe-station}/bin/vibe-station-hook
            fi
          '';
        }
      ];
    };
  };
}
```

### Option 3: Clone and Use Directly

You can clone the repository and use it directly:

```bash
# Clone the repository
git clone https://github.com/username/vibe-station.git
cd vibe-station

# Enter the development shell
nix develop

# Start code-server
code-server
```

## Running with Docker

If you prefer to run in a containerized environment, you can use Docker:

```bash
# Clone the repository
git clone https://github.com/username/vibe-station.git
cd vibe-station

# Build and start the container
docker compose up --build -d

# Access code-server at http://localhost:7080
```

For more detailed instructions, see [Running with Docker](running-with-docker.md).

## Customizing the Environment

You can customize the environment by modifying the flake.nix file:

1. Add additional packages to the `buildInputs` array in the devShells.default section
2. Modify the `shellHook` to perform additional setup
3. Add custom configurations for code-server

For example, to add additional development tools:

```nix
devShells.default = pkgs.mkShell {
  buildInputs = [
    pkgs.code-server
    pkgs.nodejs
    pkgs.go
    pkgs.python3
    # Add more packages as needed
  ];
  # Rest of your configuration...
};
```

## Troubleshooting

### Nix Issues

If you encounter Nix-related issues:
1. Ensure you have the experimental features enabled
2. Try updating Nix with `nix-channel --update`
3. Check your Nix configuration
4. If using Docker, ensure the Nix store volume is properly mounted

### code-server Issues

If you encounter issues with code-server:
1. Check the code-server documentation for troubleshooting tips
2. Ensure you're using a compatible version of code-server
3. Check for any error messages in the console
4. Verify that code-server is running with `code-server --help` to see available options

### Integration Issues

If you encounter issues integrating Vibe Station with your projects:
1. Ensure you're using the correct path in your home-manager configuration
2. Check that the flake.nix file is properly configured
3. Verify that you have the necessary permissions to access the repository
