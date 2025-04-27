# Running Vibe Station with Docker

This guide provides step-by-step instructions to run the Vibe Station code-server workspace using Docker and Docker Compose directly from the repository. While you can use the flake template approach described in [Standalone Installation](standalone-installation.md), this guide focuses on the Docker-based setup.

## Prerequisites

1.  **Docker and Docker Compose:** Ensure you have Docker and Docker Compose installed and running on your system. Refer to the official Docker documentation for installation instructions.
2.  **Nix:** While the environment runs *inside* Docker, the underlying setup uses Nix. Ensure your host machine has Nix installed with support for the experimental `nix command` and `flakes` features enabled. This is typically done by adding the following to your Nix configuration (`/etc/nix/nix.conf` or `~/.config/nix/nix.conf`):
    ```
    experimental-features = nix-command flakes
    ```
    Refer to the official Nix documentation for details.

## Running the Workspace

1.  **Clone the Repository:** If you haven't already, clone the Vibe Station repository to your local machine.
    ```bash
    # Replace with the actual repository URL
    git clone <repository-url>
    cd vibe-station
    ```
2.  **Build and Start the Container:** Use Docker Compose to build the image defined in `Dockerfile` and start the container(s) defined in `docker-compose.yml`.
    ```bash
    docker compose up --build -d
    ```
    *   `--build`: Forces Docker Compose to build the image using the `Dockerfile`.
    *   `-d`: Runs the containers in detached mode (in the background).

3.  **Access code-server:** Once the container is running, you should be able to access the code-server interface.
    *   Open your browser and navigate to `http://localhost:7080`
    *   If this is your first time, you'll need to create a password or authenticate
    *   Follow the on-screen instructions to complete the setup
    *   Once logged in, you can start using the VS Code interface in your browser

4.  **Stopping the Workspace:** To stop the running containers:
    ```bash
    docker compose down
    ```

## Notes

*   This setup currently focuses on the `linux/amd64` architecture.
*   The `flake.nix` file defines the development environment, including code-server and pre-installed tools.
*   The `shellHook` in `flake.nix` attempts to automatically install the `saoudrizwan.claude-dev` VS Code extension when the code-server workspace starts.

## Alternative Approaches

The Docker approach described in this document requires you to clone the entire repository and run Docker Compose commands manually. For a more streamlined experience, we recommend using one of the approaches described in [Standalone Installation](standalone-installation.md):

1. **Use as a Flake Template**: Create a new project using the Vibe Station template
2. **Include in Home Manager**: Add Vibe Station to your home-manager configuration
3. **Clone and Use Directly**: Clone the repository and use it without Docker

With these approaches, you can:
- Use Vibe Station with any project without requiring tight VCS integration
- Configure it with your specific requirements
- Maintain a consistent development environment across all your projects

See [Standalone Installation](standalone-installation.md) for details.
