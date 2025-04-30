# Vibe Station

A project for quickly scaffolding a vibe coding station. It leverages Nix &
Docker to quickly create a Code Server environment pre-configured with an
agentic developer, Cline.

This is an experimental project for quickly prototyping an agentic developer
experience for vibe coding.

## Features

- Nix flake template for easy integration with home-manager or standalone use
- Docker-based setup for easy deployment
- code-server pre-installed with Cline extension (`saoudrizwan.claude-dev`)
- Works with any project without requiring tight VCS integration

## Usage Options

### Option 1: Use as a Flake Template

```bash
# Create a new project using the template
mkdir my-vibe-station
cd my-vibe-station
nix flake init -t github:0xbigboss/vibe-station
```

### Option 2: Include in Home Manager

Vibe Station provides a complete Home Manager configuration with overlayed profiles:

```nix
# In your home-manager configuration
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    vibe-station.url = "github:0xbigboss/vibe-station";
  };

  outputs = { nixpkgs, home-manager, vibe-station, ... }: {
    homeConfigurations."yourusername" = home-manager.lib.homeManagerConfiguration {
      # ...
      modules = [
        # Option A: Use the complete overlayed profiles setup
        vibe-station.homeManagerModules.default

        # Option B: Or just add vibe-station to your packages
        # {
        #   home.packages = [ vibe-station.packages.${system}.code-server ];
        #   programs.bash.initExtra = ''
        #     # Add vibe-station shell hook
        #     if [ -f ${vibe-station}/bin/vibe-station-hook ]; then
        #       source ${vibe-station}/bin/vibe-station-hook
        #     fi
        #   '';
        # }
      ];
    };
  };
}
```

For detailed instructions on using the overlayed profiles, see [Nix Home Manager Overlayed Profiles](nix/home-manager/README.md).

### Option 3: Clone and Use Directly

```bash
# Clone the repository
git clone https://github.com/0xbigboss/vibe-station.git
cd vibe-station

# Enter the development shell
nix develop

# Start code-server
code-server
```

For detailed instructions on running with Docker, see [Running with Docker](docs/running-with-docker.md).

Note: This project uses code-server (https://github.com/coder/code-server), which is VS Code running on a remote server and accessible through the browser.

## Examples

- [Golang Example](examples/golang/README.md) - A simple Go HTTP server example that demonstrates how to use Vibe Station with a Go project.
- [Home Manager Overlayed Profiles](nix/home-manager/README.md) - A complete Home Manager configuration with overlayed profiles for managing your development environment.
- [Project Template](nix/home-manager/examples/project-template/README.md) - A template for creating projects that integrate with the overlayed profiles.

## Notes

- Focus on linux/amd64 for now since it's the most widely supported platform for development.
- The flake template approach allows you to use Vibe Station with any project without requiring tight VCS integration.
- Use the memory bank to save progress.
