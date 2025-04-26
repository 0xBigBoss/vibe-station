{
  description = "A basic Nix flake for the Vibe Station development environment";

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
      devShells.default = pkgs.mkShell {
        buildInputs = [
          pkgs.coder # Add the Coder package
        ];
        shellHook = ''
          echo "Welcome to the Vibe Station dev shell!"
          # Attempt to pre-install the Cline VS Code extension via Coder CLI
          # Note: This command only works when run within a Coder workspace environment.
          # We add it here so the flake provides the necessary setup.
          if command -v coder &> /dev/null; then
            echo "Attempting to install saoudrizwan.claude-dev extension..."
            coder extensions install saoudrizwan.claude-dev || echo "Failed to install extension (might not be in Coder env)."
          else
            echo "Coder CLI not found, skipping extension install."
          fi
        '';
      };
    });
}
