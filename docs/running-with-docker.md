# Running Vibe Station with Docker

This guide provides step-by-step instructions to run the Vibe Station code-server workspace using Docker and Docker Compose directly from the repository.

## Prerequisites

1. **Docker and Docker Compose:** Ensure you have Docker and Docker Compose installed and running on your system. Refer to the official Docker documentation for installation instructions.

## Running the Workspace

1. **Clone the Repository:** If you haven't already, clone the Vibe Station repository to your local machine.
   ```bash
   git clone https://github.com/0xbigboss/vibe-station.git
   cd vibe-station
   ```

2. **Build and Start the Container:** Use Docker Compose to build the image defined in `Dockerfile` and start the container(s) defined in `compose.yml`.
   ```bash
   # Standard command with output redirection (recommended)
   docker compose up --build -d > docker-build.log 2>&1

   # To reduce output verbosity
   docker compose up --build -d --quiet-pull > docker-build.log 2>&1

   # To customize the app directory (default is current directory)
   APP_DIR=/custom/path docker compose up --build -d > docker-build.log 2>&1
   ```
   * `--build`: Forces Docker Compose to build the image using the `Dockerfile`.
   * `-d`: Runs the containers in detached mode (in the background).
   * `--quiet-pull`: Reduces the output when pulling images.
   * `APP_DIR`: Optional environment variable to customize the host app directory for mounting into the container.

3. **Access code-server:** Once the container is running, you should be able to access the code-server interface.
   * Open your browser and navigate to `http://localhost:7080`
   * If this is your first time, you'll need to create a password or authenticate
   * Follow the on-screen instructions to complete the setup
   * Once logged in, you can start using the VS Code interface in your browser
   * To open a specific folder directly, use the `folder` query parameter in the URL:
     ```
     http://localhost:7080/?folder=/app/examples/golang
     ```

4. **Stopping the Workspace:** To stop the running containers:
   ```bash
   docker compose down
   ```

   If you need to reset the Nix store due to corruption:
   ```bash
   docker compose down -v
   ```
   The `-v` flag removes the volumes, which will clear the Nix store cache.

## Notes

* This setup uses a Debian-based Docker image with Nix installed in single-user mode, allowing you to run as a non-root user while still having full Nix functionality.
* The `coder` user has passwordless sudo privileges configured in the Dockerfile.
* The app directory is configurable via the `APP_DIR` environment variable on the host, allowing you to mount a project inside the container. This is useful for:
  * Mounting the project to develop within the container
* This setup currently focuses on the `linux/amd64` architecture.
* The Docker container includes a dedicated `coder` user.
* The Home Manager configuration (`nix/home-manager/home.nix`) is set to use the `coder` user by default and manages the `home-manager` package itself declaratively (`programs.home-manager.enable = true;`). The `home-manager` package is *not* pre-installed in the Docker image via `nix-env` to avoid conflicts.
* **Activating Home Manager:**
  * **Initial Activation:** Since `home-manager` isn't in the initial PATH, the first activation requires using `nix run` to fetch and execute it:
    ```bash
    # Run from your host machine
    docker compose exec code-server bash -c "cd /app/nix/home-manager && nix run github:nix-community/home-manager -- switch --flake .#coder" > home-manager-activation.log 2>&1
    ```
  * **Subsequent Activations:** After the first successful activation, the `home-manager` command will be available in the `coder` user's PATH, and you can use the standard command:
    ```bash
    # Run from your host machine
    docker compose exec code-server bash -c "cd /app/nix/home-manager && home-manager switch --flake .#coder" > home-manager-switch.log 2>&1
    ```
* The Docker Compose setup includes several volumes for caching:
  * `nix-store-data`: Caches the Nix store to speed up package installations
  * `coder-server-data`: Persists code-server settings and extensions
  * `docker-images-data`: Caches Docker images when using Docker within the container

## Customizing code-server Settings

The Vibe Station environment includes a Home Manager option to configure code-server settings. By default, it sets:
- Dark theme (`"workbench.colorTheme": "Default Dark Modern"`)
- ZSH as the default terminal (`"terminal.integrated.defaultProfile.linux": "zsh"`)

To customize these settings, you can modify the `nix/home-manager/profiles/base.nix` file:

```nix
# In nix/home-manager/profiles/base.nix
options.vibe-station = {
  code-server = {
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {
        "workbench.colorTheme" = "Default Dark Modern";
        "terminal.integrated.defaultProfile.linux" = "zsh";
        # Add your custom settings here
        "editor.fontSize" = 14;
        "editor.fontFamily" = "Fira Code, monospace";
      };
      # ...
    };
  };
};
```

After making changes, apply them by running:

```bash
# Run from your host machine
docker compose exec code-server bash -c "cd /app/nix/home-manager && home-manager switch --flake .#coder" > home-manager-switch.log 2>&1
```

The settings will be written to `/home/coder/.local/share/code-server/User/settings.json` inside the container.

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
