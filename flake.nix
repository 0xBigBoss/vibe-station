{
  description = "A Nix flake template for the Vibe Station development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      # Configure nixpkgs to allow unfree packages
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true; # Allow all unfree packages for this flake
      };
    in {
      # Define the development shell
      devShells.default = pkgs.mkShell {
        buildInputs = [
          pkgs.code-server
        ];
        shellHook = ''
          echo "Welcome to the Vibe Station dev shell!"
          # Attempt to pre-install the Cline VS Code extension via code-server CLI
          # Note: This command only works when run within a code-server workspace environment.
          # We add it here so the flake provides the necessary setup.
          if command -v code-server &> /dev/null; then
            if ! code-server --list-extensions | grep saoudrizwan.claude-dev &> /dev/null ; then
              code-server --install-extension saoudrizwan.claude-dev || echo "Failed to install extension (might not be in code-server env)."
            fi
            if ! code-server --list-extensions | grep  RooVeterinaryInc.roo-cline &> /dev/null ; then
              code-server --install-extension RooVeterinaryInc.roo-cline || echo "Failed to install extension (might not be in code-server env)."
            fi
          fi
        '';
      };

      # Add template for easy use with nix flake init
      templates = {
        default = {
          path = ./.;
          description = "A Nix flake template for the Vibe Station development environment";
        };
        project = {
          path = ./nix/home-manager/examples/project-template;
          description = "Project template with direnv integration for Vibe Station overlayed profiles";
        };
      };

      # Export Home Manager modules
      homeManagerModules = {
        default = import ./nix/home-manager/home.nix;
        base = import ./nix/home-manager/profiles/base.nix;
        personal = import ./nix/home-manager/profiles/personal.nix;
      };
    });
}
