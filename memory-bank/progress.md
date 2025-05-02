# Progress

## What Works

* Docker-based setup with Debian base image and single-user Nix installation
* Home Manager configuration with overlayed profiles:
  * Base profile with essential tools and configurations
  * Personal profile with user-specific settings
  * Project-specific environments via project flakes and direnv
* code-server pre-installed with agentic developer capabilities
* Docker-in-Docker support with volume caching for better performance
* Passwordless sudo for the coder user
* Home Manager switch in Dockerfile for initial configuration
* Comprehensive documentation for Docker usage and Home Manager configuration
* Golang example project demonstrating usage
* Project template for integration with overlayed profiles
* Browser access to code-server with folder parameter support

## What's Left to Build

* Continue implementing Docker and Home Manager enhancements:
  * Task 3: Parameterize App Directory
  * Task 4: Code-Server Settings Configuration
  * Task 5: Documentation Updates
* Consider adding more examples for other languages/frameworks
* Fully test the extension installation within a real code-server environment
* Consider mounting the host's Docker socket as a future optimization

## Current Status

* Removed the top-level flake and focused exclusively on the Docker approach with home-manager
* Updated all documentation to reflect the Docker-only approach
* Maintained project-specific flakes in examples and templates for layering environments
* The Docker setup now uses a Debian-based image with Nix installed in single-user mode, allowing users to run as a non-root user while still having full Nix functionality
* Implemented overlayed profiles in Nix Home Manager:
  * Base layer for essential tools and configurations
  * Personal layer for user-specific settings and preferences
  * Project-specific layer for project environments via direnv
* Optimized the Docker Compose setup for better performance:
  * Added a new volume `docker-images-data` to persist Docker images between container restarts
  * Updated the Docker configuration in the base profile to use the mounted volume for storing images
* Implemented a clean approach to manage `home-manager` purely declaratively:
  * Removed `home-manager` from `nix-env` installation in Dockerfile
  * Kept the declarative management in Home Manager configuration (`programs.home-manager.enable = true;`)
  * Added instructions for initial activation using `nix run` and subsequent activations using `home-manager switch`

## Known Issues

* Ruby gem warnings observed during Docker test runs (currently ignored as non-blocking)
* The extension installation needs to be tested in a real code-server environment
* The initial activation of Home Manager requires using `nix run` since the `home-manager` command isn't in the PATH until the first successful activation

## Evolution of Project Decisions

* Changed from a flake-based approach to a Docker-only approach with home-manager
* Changed the Docker base image from nixos/nix to Debian with single-user Nix to allow running as a non-root user while still having full Nix functionality
* Implemented overlayed profiles in Nix Home Manager to provide a layered approach to managing development environments
* Optimized the Docker Compose setup for better performance by adding volume caching for Docker images, while maintaining complete isolation of the container
* Decided to manage `home-manager` purely declaratively to avoid conflicts between imperative and declarative installation
