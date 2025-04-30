# Overlayed Profiles in Nix Home Manager: Implementation Plan

I'll outline a plan for creating overlayed profiles in Nix Home Manager to achieve your goal of quickly provisioning machines with base tools, personal configs, and project-specific environments.

## Understanding the Goal

You want a layered approach:
1. Base layer: Essential tools (git, docker, code-server)
2. Personal layer: Shell settings and personalized configs
3. Project-specific layer: Development environments via `nix develop` or `direnv`

## Implementation Plan

The following implementation should be done so in a way that it is easy to maintain and extend.

For now, let's keep the work together in this repository, however, move it to a sub-directory such as `home-manager` or `nix-home-manager`.

### 1. Setting Up Home Manager

First, install Home Manager if not already installed:

```bash
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
```

### 2. Creating Modular Configurations

Create a structure like this:

```
~/.config/home-manager/
├── flake.nix
├── home.nix
├── profiles/
│   ├── base.nix
│   ├── personal.nix
│   └── project-templates/
│       ├── python.nix
│       ├── node.nix
│       └── rust.nix
└── hosts/
    ├── laptop.nix
    ├── work-server.nix
    └── cloud-instance.nix
```

### 3. Implementing Base Profile

In `profiles/base.nix`:

```nix
{ config, pkgs, ... }:

{
  # Base tools
  home.packages = with pkgs; [
    git
    docker
    docker-compose
    code-server
  ];

  # Base programs configurations
  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -la";
      ".." = "cd ..";
    };
  };

  # Enable direnv for project environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
```

### 4. Creating Personal Profile

In `profiles/personal.nix`:

```nix
{ config, pkgs, ... }:

{
  # Personal Git config
  programs.git = {
    enable = true;
    userName = "Big Boss";
    userEmail = "bigboss@metalrodeo.xyz";
    extraConfig = {
      # TODO: add vscode
      core.editor = "vim";
      pull.rebase = false;
    };
  };

  # Personal shell customizations
  # TODO: add oh-my-zsh
  programs.zsh = {
    enable = true;
    initExtra = ''
      # Your personal shell customizations here
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };
}
```

### 5. Setting Up the Main Configuration

In `home.nix`:

```nix
{ config, pkgs, ... }:

{
  imports = [
    ./profiles/base.nix
    ./profiles/personal.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = "yourusername";
  home.homeDirectory = "/home/bigboss";

  # This value determines the Home Manager release that your configuration is compatible with
  home.stateVersion = "24.11";
}
```

### 6. Creating Host-Specific Configurations (Optional)

For different machines, create specific configs in the `hosts/` directory.

In `hosts/work-server.nix`:

```nix
{ config, pkgs, ... }:

{
  imports = [
    ../profiles/base.nix
    ../profiles/personal.nix
  ];

  # Work-specific configurations
  home.packages = with pkgs; [
    kubernetes
    awscli
  ];
}
```

### 7. Using Flakes for Better Management

Create a `flake.nix` in your Home Manager directory:

```nix
{
  description = "Home Manager configuration with layered profiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux"; # Adjust for your system
      pkgs = nixpkgs.legacyPackages.${system};
      username = "yourusername"; # Your username
    in {
      homeConfigurations = {
        # Default configuration
        ${username} = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
        };

        # Work server configuration
        "work-${username}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./hosts/work-server.nix ];
        };

        # Add more configurations as needed
      };
    };
}
```

### 8. Project-Specific Development Environments

Create a template `.envrc` file for your projects:

```bash
# Put this in your project directory
use flake
```

And a `flake.nix` for the project:

```nix
{
  description = "Project development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Project-specific dependencies here
            python310
            python310Packages.pip
            poetry
          ];

          shellHook = ''
            # Environment setup
            echo "Project development environment loaded!"
          '';
        };
      }
    );
}
```

## Execution Steps for Engineers

1. **Install Nix and Home Manager**:
   - Install Nix: `sh <(curl -L https://nixos.org/nix/install) --daemon`
   - Enable flakes: Add `experimental-features = nix-command flakes` to `/etc/nix/nix.conf`
   - Install Home Manager as described above

2. **Create Configuration Structure**:
   - Set up the directory structure shown above
   - Implement the base profile
   - Implement the personal profile
   - For now, skip the host-specific profiles

3. **Apply Configuration**:
   - If using flakes: `nix run home-manager/master -- switch --flake .#yourusername`
   - If not using flakes: `home-manager switch`

4. **For Project-Specific Environments**:
   - Create a `flake.nix` in each project directory
   - Add an `.envrc` file with `use flake`
   - Run `direnv allow` to enable the environment

5. **For New Machines**:
   - Clone your Home Manager config repository
   - Create a host-specific configuration if needed
   - Run the appropriate switch command

This approach provides a modular, layered configuration that satisfies all your requirements while maintaining flexibility for different machines and projects.


## Testing

Use the the same or similar vibe-statioon docker and docker compose step. Aim to to test the integration of our new nix-based home manager configuration with overlayed profiles.
