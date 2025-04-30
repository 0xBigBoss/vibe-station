{
  description = "Vibe Station Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  }: let
    # Define supported systems - adjust if needed
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

    # Helper function to generate configurations for each system
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # Define the primary username - users should customize this in home.nix
    # We reference it here to build the output structure.
    # A default value is provided, but home.nix is the source of truth.
    defaultUsername = "coder"; # Username for Docker container
  in {
    # Define homeConfigurations output
    homeConfigurations = {
      # Default configuration for the primary user
      "${defaultUsername}" = let
        system = "x86_64-linux"; # Default to x86_64-linux for Docker testing
        pkgs = nixpkgs.legacyPackages.${system};
      in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          # The core modules for this configuration
          modules = [
            ./home.nix
            # Potentially add host-specific modules here later
          ];
          # Optional extra arguments passed to modules
          extraSpecialArgs = {
            # Add any extra arguments needed by your modules
            # inherit inputs; # Example: pass flake inputs down
          };
        };

      # Example of how to add other configurations (e.g., for different hosts)
      # "work-${defaultUsername}" =
      #   let
      #     system = "x86_64-linux";
      #     pkgs = nixpkgs.legacyPackages.${system};
      #   in
      #   home-manager.lib.homeManagerConfiguration {
      #     inherit pkgs;
      #     modules = [ ./hosts/work-server.nix ]; # Assuming hosts/work-server.nix exists
      #   };
    };

    # Export Home Manager modules for use in other flakes
    homeManagerModules = {
      # Default module that provides the complete overlayed profiles setup
      default = {pkgs, ...}: {
        imports = [
          ./home.nix
        ];
      };

      # Individual profile modules for more granular inclusion
      base = {pkgs, ...}: {
        imports = [
          ./profiles/base.nix
        ];
      };

      personal = {pkgs, ...}: {
        imports = [
          ./profiles/personal.nix
        ];
      };
    };

    # Templates for creating new projects that integrate with overlayed profiles
    templates = {
      project = {
        path = ./examples/project-template;
        description = "Project template with direnv integration for Vibe Station overlayed profiles";
      };
    };
  };
}
