# Vibe Station

A project for quickly scaffolding a vibe coding station. It leverages Docker and Home Manager to quickly create a Code Server environment pre-configured with an agentic developer experience.

This is an experimental project for quickly prototyping an agentic developer experience for vibe coding.

## Features

- Docker-based setup for easy deployment and consistent environment
- Home Manager configuration for declarative environment management
- code-server pre-installed with agentic developer capabilities
- Works with any project without requiring tight VCS integration
- Compose override feature for customizing the Code Server environment
- Persistent user data across container restarts via Docker volumes

## Recommended Quickstart

Clone the vibe-station repo into a subdirectory of your project and run the following commands:

```bash
# Clone the vibe-station repo
git clone https://github.com/0xbigboss/vibe-station.git .vibe-station
# Ignore the .vibe-station directory in your project
echo ".vibe-station" >> .git/info/exclude
# Run the vibe-station docker-compose command
docker compose up -d -f .vibe-station/compose.yml
# Find the random port assigned by docker compose. Use `HOST_PORT` environment variable to specify a custom port.
docker compose ps
```

Now you can access the code-server interface at `http://localhost:7080` or the random port assigned by docker compose, `docker compose ps` and use that port.

## Getting Started with Docker

### Prerequisites

1. **Docker and Docker Compose:** Ensure you have Docker and Docker Compose installed and running on your system. Refer to the official Docker documentation for installation instructions.

### Running Vibe Station

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/0xbigboss/vibe-station.git
   cd vibe-station
   ```

2. **Build and Start the Container:**
   ```bash
   # Standard command for testing vibe-station (redirect output to reduce verbosity)
   HOST_PORT=7080 docker compose up --build -d > docker-build.log 2>&1

   # To customize the app directory (default is current directory)
   APP_DIR=/path/to/your/project \
   HOST_PORT=7080 \
      docker compose up --build -d > docker-build.log 2>&1
   ```

3. **Access code-server:**
   - Open your browser and navigate to `http://localhost:7080` or the find the random port assigned by docker compose, `docker compose ps` and use that port.
   - Follow the on-screen instructions to complete the setup
   - Once logged in, you can start using the VS Code interface in your browser

4. **Stopping the Workspace:**
   ```bash
   docker compose down
   ```

   If you need to reset the Nix store due to corruption:
   ```bash
   docker compose down -v
   ```

## Home Manager Configuration

Vibe Station uses Home Manager within the Docker container to manage the development environment. The configuration is organized into profiles:

- **Base Profile**: Essential tools and configurations
- **Personal Profile**: User-specific configurations and preferences

### Activating Home Manager Changes

After making changes to the Home Manager configuration:

```bash
# Run from your host machine (redirect output to reduce verbosity)
docker compose exec code-server bash -c "cd /app/nix/home-manager && home-manager switch --flake .#coder" > home-manager-switch.log 2>&1
```

## Customizing Your Environment

You can customize the environment by modifying the Home Manager configuration files:

- `nix/home-manager/profiles/base.nix`: Essential tools and configurations
- `nix/home-manager/profiles/personal.nix`: User-specific configurations and preferences

For example, to customize code-server settings, modify the `vibe-station.code-server.settings` option in `nix/home-manager/profiles/base.nix`.

## User Data Persistence

Vibe Station ensures that important user data is preserved across container restarts and updates through Docker named volumes:

- **XDG directories**: Configuration (`~/.config`), data (`~/.local`), and cache (`~/.cache`) directories
- **Nix profile**: User's Nix profile (`~/.nix-profile`)
- **Code Server data**: Code Server-specific settings and extensions
- **Docker images**: Container images built or pulled during use

This persistence is especially important for agentic tools and applications that rely on the XDG Base Directory Specification to store their data.

For more details on user data persistence, see [User Data Persistence](docs/user-data-persistence.md).

## Docker Compose Override

To customize the Code Server environment, you can create a `compose.override.yml` file in the root of your project. This file can override or extend the default `compose.yml` file.

For example, you can add a proxy to the code-server container:

```yml
# Example of adding a proxy to the code-server container
services:
  tilt:
   image: alpine/socat
   container_name: tilt
   restart: unless-stopped
   command: TCP-LISTEN:10350,fork,reuseaddr TCP:code-server:10350
   ports:
      - "10350"
   depends_on:
      - code-server
```

## Examples

- [Golang Example](examples/golang/README.md) - A simple Go HTTP server example that demonstrates how to use Vibe Station with a Go project.
- [Home Manager Overlayed Profiles](nix/home-manager/README.md) - A complete Home Manager configuration with overlayed profiles for managing your development environment.

## Documentation

For more detailed instructions and information, see:

- [Running with Docker](docs/running-with-docker.md) - Comprehensive guide to running Vibe Station with Docker
- [Customizing Data Persistence](docs/customizing-data-persistence.md) - Guide for persisting additional directories and customizing data persistence

## Community

Join our Discord community to get help, share your experiences, and connect with other users:

- [Discord Server](https://discord.gg/uc6uSBQtve) - Join the Vibe Station community

## Notes

- Focus on linux/amd64 for now since it's the most widely supported platform for development.
- Use the memory bank to save progress.
