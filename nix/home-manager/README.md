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

## Using with Docker

The Vibe Station Docker container uses a Debian-based image with Nix installed in single-user mode, allowing you to run as a non-root user while still having full Nix functionality. The container includes Home Manager and a dedicated `coder` user for running Home Manager commands.

### Activating Home Manager in Docker

```bash
# Initial Activation (if home-manager command isn't available yet):
docker compose exec code-server bash -c "cd /app/nix/home-manager && nix run github:nix-community/home-manager -- switch --flake .#coder" > home-manager-activation.log 2>&1

# Subsequent Activations (after the first successful run):
docker compose exec code-server bash -c "cd /app/nix/home-manager && home-manager switch --flake .#coder" > home-manager-switch.log 2>&1
```

**Important Notes on Docker Usage:**
- The Docker container includes a dedicated `coder` user.
- The Home Manager configuration (`home.nix`) uses the `coder` user by default and manages the `home-manager` package itself declaratively (`programs.home-manager.enable = true;`). The `home-manager` package is *not* pre-installed in the Docker image via `nix-env` to avoid conflicts.
- The initial activation requires `nix run` because the `home-manager` command isn't in the PATH until the first successful switch.

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

## Troubleshooting

### Common Issues

- **"Cannot build derivation":** Ensure all package names are correct and available in nixpkgs
- **Flake errors:** Verify your flake.nix syntax and that all inputs are accessible
- **Home Manager errors:** Check the Home Manager manual for correct module options

### Getting Help

- Refer to the [Home Manager Manual](https://nix-community.github.io/home-manager/options.html)
- Check the [Nix documentation](https://nixos.org/manual/nix/stable/)
- Join the [NixOS Discourse](https://discourse.nixos.org/) or [Matrix channel](https://matrix.to/#/#home-manager:nixos.org)
