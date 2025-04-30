# Project Template with Vibe Station Overlayed Profiles

This directory contains a template for creating projects that integrate with Vibe Station's overlayed profiles in Home Manager. It demonstrates how to set up a project-specific development environment that builds upon your base and personal profiles.

## How Overlayed Profiles Work with Projects

The overlayed profiles approach creates a seamless development experience through three layers:

1. **Base Profile** (from Home Manager): Essential tools and configurations
2. **Personal Profile** (from Home Manager): Your personal preferences and settings
3. **Project Environment** (this directory): Project-specific tools and settings

When you enter this directory with direnv enabled, the project environment is automatically activated on top of your existing Home Manager configuration.

## Files in this Template

- **flake.nix**: Defines the project-specific development environment
- **.envrc**: Activates the environment using direnv
- **README.md**: This documentation file

## Using this Template

### Prerequisites

1. You have set up the Vibe Station Home Manager configuration
2. You have enabled direnv in your base profile
3. You have applied the Home Manager configuration to your system

### Setup Steps

1. **Copy this Template**: Copy this directory to your project location
   ```bash
   cp -r /path/to/vibe-station/nix/home-manager/examples/project-template /path/to/your/project
   ```

2. **Customize the Environment**: Edit `flake.nix` to include the packages and tools specific to your project
   ```nix
   # In flake.nix, modify the buildInputs section:
   buildInputs = with pkgs; [
     # Add your project-specific dependencies
     nodejs
     yarn
     # ...other packages
   ];
   ```

3. **Customize the Shell Hook**: Edit the `shellHook` in `flake.nix` to set up your project environment
   ```nix
   shellHook = ''
     echo "Project environment loaded!"
     # Add project-specific initialization
     yarn install
     # ...other setup commands
   '';
   ```

4. **Allow direnv**: Run this command in your project directory
   ```bash
   direnv allow
   ```

5. **Start Developing**: The environment will be automatically loaded whenever you enter the directory

## Integration with Home Manager

This project environment builds on top of your Home Manager configuration:

- **Tools from Base Profile**: All tools installed in your base profile (git, docker, etc.) are available
- **Personal Settings**: Your personal Git configuration, shell aliases, etc. are applied
- **Project-Specific Tools**: Only the additional tools needed for this project are added

## Testing the Integration

To verify that the integration is working correctly:

1. **Check Available Tools**: Run `which git` to confirm it's using the one from your Home Manager configuration
2. **Check Git Configuration**: Run `git config user.name` to confirm it's using your personal settings
3. **Check Project Tools**: Run `which jq` to confirm the project-specific tools are available

## Troubleshooting

- **Environment Not Loading**: Ensure direnv is enabled and you've run `direnv allow`
- **Missing Tools**: Check that the packages are correctly specified in `flake.nix`
- **Conflicts**: If you encounter conflicts between Home Manager and project packages, consider using `pkgs.buildEnv` to create a more controlled environment
