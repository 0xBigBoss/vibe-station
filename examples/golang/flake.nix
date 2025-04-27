{
  description = "Golang example project for Vibe Station";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.go
          ];
          shellHook = ''
            echo "Welcome to the Golang example project!"
            echo "Run 'go run main.go' to start the server"
          '';
        };
      });
}
