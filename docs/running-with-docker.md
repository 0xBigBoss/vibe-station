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
    # Standard command
    docker compose up --build -d

    # To reduce output verbosity
    docker compose up --build -d --quiet-pull

    # To redirect verbose output to a log file
    docker compose up --build -d > docker-build.log 2>&1
    ```
    *   `--build`: Forces Docker Compose to build the image using the `Dockerfile`.
    *   `-d`: Runs the containers in detached mode (in the background).
    *   `--quiet-pull`: Reduces the output when pulling images.

3.  **Access code-server:** Once the container is running, you should be able to access the code-server interface.
    *   Open your browser and navigate to `http://localhost:7080`
    *   If this is your first time, you'll need to create a password or authenticate
    *   Follow the on-screen instructions to complete the setup
    *   Once logged in, you can start using the VS Code interface in your browser
    *   To open a specific folder directly, use the `folder` query parameter in the URL:
        ```
        http://localhost:7080/?folder=/app/examples/golang
        ```

4.  **Stopping the Workspace:** To stop the running containers:
    ```bash
    docker compose down
    ```

    If you need to reset the Nix store due to corruption:
    ```bash
    docker compose down -v
    ```
    The `-v` flag removes the volumes, which will clear the Nix store cache.

## Notes

*   This setup uses a Debian-based Docker image with Nix installed in single-user mode, allowing you to run as a non-root user while still having full Nix functionality.
*   The `coder` user has passwordless sudo privileges configured in the Dockerfile.
*   This setup currently focuses on the `linux/amd64` architecture.
*   The `flake.nix` file defines the development environment, including code-server and pre-installed tools.
*   The `shellHook` in `flake.nix` attempts to automatically install the `saoudrizwan.claude-dev` VS Code extension when the code-server workspace starts.
*   The Docker container includes a dedicated `coder` user.
*   The Home Manager configuration (`nix/home-manager/home.nix`) is set to use the `coder` user by default and manages the `home-manager` package itself declaratively (`programs.home-manager.enable = true;`). The `home-manager` package is *not* pre-installed in the Docker image via `nix-env` to avoid conflicts.
*   **Activating Home Manager:**
    *   **Initial Activation:** Since `home-manager` isn't in the initial PATH, the first activation requires using `nix run` to fetch and execute it:
        ```bash
        # Run from your host machine
        docker compose exec code-server bash -c "cd /app/nix/home-manager && nix run github:nix-community/home-manager -- switch --flake .#coder"

        # To redirect verbose output to a log file
        docker compose exec code-server bash -c "cd /app/nix/home-manager && nix run github:nix-community/home-manager -- switch --flake .#coder" > home-manager-activation.log 2>&1
        ```
    *   **Subsequent Activations:** After the first successful activation, the `home-manager` command will be available in the `coder` user's PATH, and you can use the standard command:
        ```bash
        # Run from your host machine
        docker compose exec code-server bash -c "cd /app/nix/home-manager && home-manager switch --flake .#coder"

        # To redirect verbose output to a log file
        docker compose exec code-server bash -c "cd /app/nix/home-manager && home-manager switch --flake .#coder" > home-manager-switch.log 2>&1
        ```
*   The Docker Compose setup includes several volumes for caching:
    *   `nix-store-data`: Caches the Nix store to speed up package installations
    *   `coder-server-data`: Persists code-server settings and extensions
    *   `docker-images-data`: Caches Docker images when using Docker within the container

## Managing Command Output

When running commands that produce extensive output (like Nix builds or Docker operations), consider using one of these approaches to prevent filling up your terminal or context window:

1. **Redirect to log files** when you need to preserve the full output:
   ```bash
   command > output.log 2>&1
   ```

2. **Use quiet flags** when available:
   - `--quiet` or `-q` for many commands
   - `--quiet-pull` for Docker Compose
   - `--no-progress` for some Docker operations

3. **Filter output** with grep or other tools:
   ```bash
   command | grep "important info"
   ```

4. **Use silent mode** for commands that support it:
   ```bash
   command -s
   ```

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
