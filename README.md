# Vibe Station

A workspace for vibe coding. It leverages Nix to quickly create a Coder environment
pre-configured with an agentic developer, Cline.

It assumes that you already have Nix installed and configured with support for
the experimental nix command and flakes features.

## Features

- Docker-based setup for easy deployment
- Nix flake that includes Coder pre-installed
- Pre-installation of Cline extension (`saoudrizwan.claude-dev`)
- Example projects to demonstrate usage

## Getting Started

See [Running with Docker](docs/running-with-docker.md) for step-by-step instructions on how to run the Vibe Station Coder workspace on your machine.

## Examples

- [Golang Example](examples/golang/README.md) - A simple Go HTTP server example that demonstrates how to use Vibe Station with a Go project.

## TODO

- [x] Need step-by-step instructions for a user to run the Vibe Station coder workspace on their machine using docker
- [x] Create a nix flake that includes Coder pre-installed
- [x] Pre-install Cline extension `saoudrizwan.claude-dev`
- [x] Examples of using the Vibe Station Coder workspace
  - [x] Golang project only for now.

## Notes

- Focus on linux/amd64 for now so we can prove the concept since linux amd64 is the most
widely supported platform development.
- The examples let users bring their own nix flakes so that the coder workspace can be used for any project.
- Use the memory bank to save progress.
