# Active Context

## Current Focus

* Removed the top-level flake and focused exclusively on the Docker approach with home-manager
* Updated all documentation to reflect the Docker-only approach
* Maintained project-specific flakes in examples and templates for layering environments
* Optimized the Docker Compose setup to cache Docker-in-Docker images for better performance
* Successfully tested the code-server functionality through the browser interface
* Implemented overlayed profiles in Nix Home Manager to provide a layered approach to managing development environments

## Recent Changes

* Removed top-level flake.nix and flake.lock files
* Removed standalone-installation.md documentation
* Updated README.md to focus solely on the Docker approach
* Updated docs/running-with-docker.md to position it as the primary/only installation method
* Updated examples/golang/README.md to remove references to the top-level flake
* Updated nix/home-manager/README.md to focus on Docker usage
* Kept project-specific flakes in examples and templates to demonstrate environment layering
* Changed the Docker base image from nixos/nix to Debian with single-user Nix installation:
  * Switched to debian:bookworm as the base image
  * Installed Nix in single-user mode for the non-root 'coder' user
  * Added necessary configurations to enable flakes and other Nix features
  * Configured passwordless sudo for the coder user via `/etc/sudoers.d/coder`
* Resolved conflict between imperative and declarative installation of `home-manager`:
  * Removed `home-manager` from `nix-env` installation in Dockerfile to avoid activation conflicts
  * Kept the declarative management in Home Manager configuration (`programs.home-manager.enable = true;` in home.nix)
  * Updated documentation to provide clear guidance on initial activation using `nix run github:nix-community/home-manager -- switch --flake .#coder` and subsequent activations using `home-manager switch --flake .#coder`
* Added Docker-in-Docker support with volume caching:
  * Added a new volume `docker-images-data` to persist Docker images between container restarts
  * Updated the Docker configuration in the base profile to use the mounted volume for storing images
  * Updated documentation to explain the volume caching system

## Next Steps

1. Continue implementing Docker and Home Manager enhancements as outlined in `docs/todo/docker-home-manager-enhancements.md`:
   * ✅ Task 1: Passwordless sudo for coder user - Completed
   * ✅ Task 2: Home Manager switch in Dockerfile - Completed
   * Task 3: Parameterize the `/app` directory using an ENV variable
   * Task 4: Create a Home Manager option to configure `code-server` settings
   * Task 5: Update documentation for these changes
2. Consider adding more examples for other languages/frameworks
3. Fully test the extension installation within a real code-server environment
4. Consider mounting the host's Docker socket as a future optimization to allow the container to use the host's Docker daemon instead of running Docker-in-Docker

## Active Decisions & Considerations

* Focused exclusively on the Docker approach with home-manager, removing the top-level flake
* Maintained project-specific flakes in examples and templates to demonstrate environment layering
* Changed the Docker base image from nixos/nix to Debian with single-user Nix to allow running as a non-root user while still having full Nix functionality
* Implemented a layered approach to managing development environments with overlayed profiles:
  * Base layer for essential tools and configurations
  * Personal layer for user-specific settings and preferences
  * Project-specific layer for project environments via direnv
* Decided to optimize Docker-in-Docker performance by adding volume caching for Docker images while maintaining complete isolation of the container, rather than mounting the host's Docker socket which would have been faster but less isolated
* Decided to manage `home-manager` purely declaratively (`programs.home-manager.enable = true;`) and removed the imperative installation from the Dockerfile to resolve activation conflicts

## Learnings & Insights

* Using Debian with single-user Nix installation provides better flexibility for running as a non-root user while maintaining full Nix functionality
* The code-server `folder` query parameter (e.g., `http://localhost:7080/?folder=/app/examples/golang`) provides a convenient way to directly open specific folders, improving the user experience
* Overlayed profiles provide a modular approach to managing development environments:
  * Modularity: Easily add, remove, or modify specific aspects of the configuration
  * Portability: Apply consistent configurations across different machines
  * Maintainability: Simpler to update and extend over time
  * Flexibility: Mix and match profiles based on needs (e.g., work vs. personal machines)
* Direnv integration with Nix flakes creates a seamless development experience by automatically loading project-specific environments
* Docker volume caching provides significant performance benefits for Docker-in-Docker operations
* Installing `home-manager` both imperatively and declaratively causes conflicts during `home-manager switch`. The solution is to rely solely on declarative management and use `nix run` for the initial activation if the command isn't in the PATH
