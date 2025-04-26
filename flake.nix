{
  description = "A basic Nix flake for the Vibe Station development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.cowsay # A simple package to test
            pkgs.lolcat # Another simple package to test
          ];
          shellHook = ''
            echo "Welcome to the Vibe Station dev shell!"
          '';
        };
      });
}
