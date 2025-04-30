{
  description = "Example project using Vibe Station overlayed profiles";

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
            # Project-specific dependencies
            # Uncomment or add packages as needed for your project
            # nodejs
            # python3
            # go
            # rustc
            # cargo

            # Example development tools
            jq
            yq
          ];

          shellHook = ''
            echo "🚀 Project development environment loaded!"
            echo "This environment extends your Home Manager configuration with project-specific tools."
            echo ""
            echo "Your base profile provides: git, docker, etc."
            echo "Your personal profile provides: custom git config, shell settings, etc."
            echo "This project environment adds: jq, yq, etc."
            echo ""
          '';
        };
      }
    );
}
