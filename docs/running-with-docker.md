# Running Vibe Station with Docker

This guide provides step-by-step instructions to run the Vibe Station Coder workspace using Docker and Docker Compose.

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

3.  **Access Coder:** Once the container is running, you should be able to access the Coder dashboard.
    *   Open your browser and navigate to `http://localhost:7080`
    *   If this is your first time, you'll need to create an admin user
    *   Follow the on-screen instructions to complete the setup
    *   Once logged in, you can create a new workspace using the Vibe Station template

4.  **Stopping the Workspace:** To stop the running containers:
    ```bash
    docker compose down
    ```

## Notes

*   This setup currently focuses on the `linux/amd64` architecture.
*   The `flake.nix` file defines the development environment, including Coder and pre-installed tools.
*   The `shellHook` in `flake.nix` attempts to automatically install the `saoudrizwan.claude-dev` VS Code extension when the Coder workspace starts.
