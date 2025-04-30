# Vibe Station Home Manager Configuration with Overlayed Profiles

This directory contains a Nix Home Manager configuration designed for the Vibe Station project, providing a layered approach to managing development environments and user settings through overlayed profiles.

## What are Overlayed Profiles?

Overlayed profiles are a modular approach to managing your development environment configuration. Instead of having a single monolithic configuration file, you split your configuration into logical layers that can be combined and customized as needed:

1. **Base Layer (`profiles/base.nix`):** Essential tools and configurations that should be available on any machine you use (git, docker, shell basics, etc.)
2. **Personal Layer (`profiles/personal.nix`):** Your personal preferences and configurations (Git identity, shell customizations, editor settings)
3. **Project-Specific Layer:** (Via project flakes and direnv) Development environments specific to individual projects

This approach offers several benefits:
- **Modularity:** Easily add, remove, or modify specific aspects of your configuration
- **Portability:** Apply consistent configurations across different machines
- **Maintainability:** Simpler to update and extend over time
- **Flexibility:** Mix and match profiles based on your needs (e.g., work vs. personal machines)

## Prerequisites

- **Nix:** Ensure Nix is installed with Flakes enabled
  ```bash
  # Install Nix (if not already installed)
  sh <(curl -L https://nixos.org/nix/install) --daemon

  # Enable flakes by adding this to /etc/nix/nix.conf or ~/.config/nix/nix.conf
  experimental-features = nix-command flakes
  ```

- **Git:** Required for cloning the repository and managing configurations
- **Direnv:** (Optional but recommended) For automatic project environment activation

## Directory Structure

```
nix/home-manager/
├── flake.nix              # Manages inputs and defines configurations
├── home.nix               # Main configuration file that imports profiles
├── profiles/
│   ├── base.nix           # Essential tools and configurations
│   ├── personal.nix       # User-specific settings and preferences
│   └── [other].nix        # Additional profiles you might create
└── README.md              # This documentation
```

## Quick Start Guide

### 1. Initial Setup

```bash
# Clone the repository (if you haven't already)
git clone https://github.com/username/vibe-station.git
cd vibe-station/nix/home-manager

# Customize the configuration for your system
# (See the "Customization" section below)

# Test your configuration (optional but recommended)
./test-profiles.sh
```

### 2. Customize Configuration Files

Edit these files to match your preferences:

- **home.nix:** Set your username and home directory path
  ```nix
  home.username = "yourusername"; # Replace with your actual username
  home.homeDirectory = "/home/yourusername"; # Replace with your actual home path
  ```

- **profiles/personal.nix:** Set your personal information
  ```nix
  programs.git = {
    userName = "Your Name"; # Replace with your name
    userEmail = "your.email@example.com"; # Replace with your email
    # Other personal preferences...
  };
  ```

### 3. Apply the Configuration

```bash
# Apply the configuration to your system
# Replace 'yourusername' with the username you set in home.nix
nix run home-manager/master -- switch --flake .#yourusername
```

## Detailed Usage Guide

### Understanding the Profile Layers

#### Base Profile (`profiles/base.nix`)

The base profile contains essential tools and configurations that should be consistent across all your machines:

- Core command-line tools (git, curl, wget, etc.)
- Shell configuration basics (zsh with common aliases)
- Development tools (docker, direnv)

You can customize this profile to include tools you consider essential for any development environment.

#### Personal Profile (`profiles/personal.nix`)

The personal profile contains your individual preferences and identity:

- Git user information and preferences
- Personal shell customizations and aliases
- Editor configurations and preferences

This profile should contain settings that are specific to you but not tied to any particular project.

#### Project-Specific Environments

Project environments are handled through individual project flakes and direnv:

1. Each project has its own `flake.nix` defining its development environment
2. An `.envrc` file in the project directory activates the environment
3. Direnv automatically loads/unloads the environment when you enter/exit the directory

### Creating Additional Profiles

You can create additional profiles for specific purposes:

```bash
# Create a new profile
touch profiles/work.nix

# Edit the profile with your preferred editor
# Then import it in home.nix
```

Example work profile (`profiles/work.nix`):
```nix
{ config, pkgs, lib, ... }:

{
  # Work-specific packages
  home.packages = with pkgs; [
    awscli
    kubernetes
    terraform
  ];

  # Work-specific configurations
  programs.git = {
    includes = [{ path = "~/.gitconfig-work"; }];
  };
}
```

Then import it in `home.nix`:
```nix
imports = [
  ./profiles/base.nix
  ./profiles/personal.nix
  ./profiles/work.nix  # Add your new profile here
];
```

## Testing with Docker

The Vibe Station Docker container uses a Debian-based image with Nix installed in single-user mode, allowing you to run as a non-root user while still having full Nix functionality. The container includes Home Manager and a dedicated `coder` user for running Home Manager commands. We provide a convenient testing script that automates the validation process:

```bash
# Run the testing script
./test-profiles.sh
```

This script will:
1. Check prerequisites (Docker and Docker Compose)
2. Start the Docker container
3. Validate your Home Manager configuration syntax
4. Test packages from your base profile
5. Verify direnv configuration
6. Provide a summary and next steps

You can also run tests manually:

```bash
# Start the Docker container
docker compose up --build -d code-server

# Test building the configuration (syntax check)
docker compose exec code-server bash -c "cd /app/nix/home-manager && home-manager build --flake .#coder --no-out-link"

# Test if packages from your profiles are available
docker compose exec code-server bash -c "nix-shell -p cowsay --run \"cowsay Testing packages from profiles\""

# Apply the configuration (full test)
docker compose exec code-server bash -c "cd /app/nix/home-manager && nix run home-manager/master -- switch --flake .#coder"
```

**Important Notes on Docker Testing:**
- Docker testing primarily validates syntax and package availability
- The Docker container includes a dedicated `coder` user for running Home Manager commands
- The Home Manager configuration is set to use the `coder` user by default
- The Docker container environment is ephemeral and may differ from your actual system

## Customization

### Adding Packages

To add packages to your environment:

```nix
# In profiles/base.nix or profiles/personal.nix
home.packages = with pkgs; [
  existing-package
  new-package1
  new-package2
  # ...
];
```

### Configuring Programs

Home Manager provides modules for configuring many common programs:

```nix
# Example: Configure Neovim
programs.neovim = {
  enable = true;
  viAlias = true;
  vimAlias = true;
  extraConfig = ''
    set number
    set relativenumber
  '';
};
```

### Platform-Specific Configuration

For cross-platform compatibility:

```nix
# Example: Platform-specific packages
home.packages = with pkgs; [
  # Common packages
  git
  curl
] ++ lib.optionals stdenv.isLinux [
  # Linux-only packages
  inotify-tools
] ++ lib.optionals stdenv.isDarwin [
  # macOS-only packages
  cocoa-dialog
];
```

## Project Templates

We provide a project template that demonstrates how to integrate with the overlayed profiles:

```
examples/project-template/
├── flake.nix              # Project-specific development environment
├── .envrc                 # Direnv configuration to activate the environment
└── README.md              # Documentation on using the template
```

To use the template:

```bash
# Copy the template to your project
cp -r /path/to/vibe-station/nix/home-manager/examples/project-template /path/to/your/project

# Customize the flake.nix for your project's needs
# Edit /path/to/your/project/flake.nix

# Allow direnv to use the environment
cd /path/to/your/project
direnv allow
```

See the [Project Template README](examples/project-template/README.md) for detailed instructions.

## Integration with Vibe Station

This Home Manager configuration is designed to work seamlessly with the broader Vibe Station project:

1. **Standalone Usage:** Use this configuration independently to manage your development environment
2. **With code-server:** Combine with code-server for a complete development environment
3. **Project Integration:** Use with project-specific flakes for per-project environments (see the [Project Template](examples/project-template/))

## Troubleshooting

### Common Issues

- **"Cannot build derivation":** Ensure all package names are correct and available in nixpkgs
- **Flake errors:** Verify your flake.nix syntax and that all inputs are accessible
- **Home Manager errors:** Check the Home Manager manual for correct module options

### Getting Help

- Refer to the [Home Manager Manual](https://nix-community.github.io/home-manager/options.html)
- Check the [Nix documentation](https://nixos.org/manual/nix/stable/)
- Join the [NixOS Discourse](https://discourse.nixos.org/) or [Matrix channel](https://matrix.to/#/#home-manager:nixos.org)
