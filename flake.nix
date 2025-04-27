{
  description = "A Nix flake template for the Vibe Station development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
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
          pkgs.code-server # Add the code-server package
        ];
        shellHook = ''
          echo "Welcome to the Vibe Station dev shell!"
          # Attempt to pre-install the Cline VS Code extension via code-server CLI
          # Note: This command only works when run within a code-server workspace environment.
          # We add it here so the flake provides the necessary setup.
          if command -v code-server &> /dev/null; then
            echo "Attempting to install saoudrizwan.claude-dev extension..."
            # code-server --install-extension saoudrizwan.claude-dev || echo "Failed to install extension (might not be in code-server env)."
          else
            echo "code-server CLI not found, skipping extension install."
          fi
        '';
      };

      # Add template for easy use with nix flake init
      templates.default = {
        path = ./.;
        description = "A Nix flake template for the Vibe Station development environment";
      };
    });
}
