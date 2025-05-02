# Customizing Data Persistence

This guide explains how to customize data persistence in vibe-station to ensure that your important files and directories are preserved across container restarts.

## Current Persistence Configuration

By default, vibe-station persists the following directories:

- `/nix` (Nix store)
- `/home/coder/.local/share/code-server` (Code Server data)
- `/home/coder/.config` (XDG config directory)
- `/home/coder/.local` (XDG local directory)
- `/home/coder/.cache` (XDG cache directory)
- `/home/coder/.nix-profile` (Nix profile)
- `/var/lib/docker` (Docker images data)

These directories are persisted using Docker named volumes, which are managed by Docker and survive container restarts and rebuilds.

## Adding Custom Persistent Directories

If you have additional directories that need to be persisted, you can customize the persistence configuration using Docker Compose's override feature.

### Using compose.override.yml

1. Create a `compose.override.yml` file in the same directory as the `compose.yml` file:

```yaml
services:
  code-server:
    volumes:
      # Add your custom volume mappings here
      - custom-data:/home/coder/custom-directory
      - project-data:/home/coder/projects
      - dotfiles-data:/home/coder/.dotfiles

volumes:
  # Define your custom volumes here
  custom-data:
  project-data:
  dotfiles-data:
```

2. Run Docker Compose with both files:

```bash
# Using the COMPOSE_FILE environment variable
COMPOSE_FILE=compose.yml:compose.override.yml docker compose up -d > docker-build.log 2>&1

# Or using the -f flag (multiple times)
docker compose -f compose.yml -f compose.override.yml up -d > docker-build.log 2>&1
```

### Example: Persisting Tool-Specific Directories

Many tools store data in specific directories within the home directory. Here's an example for common tools:

```yaml
services:
  code-server:
    volumes:
      # Language-specific tool data
      - node-modules-data:/home/coder/.npm
      - go-data:/home/coder/go
      - rust-data:/home/coder/.cargo
      - python-data:/home/coder/.local/lib/python3.10
      
      # VCS data
      - git-data:/home/coder/.git
      
      # Shell history and configuration
      - zsh-data:/home/coder/.zsh_history
      - bash-data:/home/coder/.bash_history
      
      # SSH keys and configuration
      - ssh-data:/home/coder/.ssh

volumes:
  # Define the corresponding volumes
  node-modules-data:
  go-data:
  rust-data:
  python-data:
  git-data:
  zsh-data:
  bash-data:
  ssh-data:
```

### Example: Persisting the Entire Home Directory

If you want to persist the entire home directory, you can use a single volume:

```yaml
services:
  code-server:
    volumes:
      - coder-home-data:/home/coder

volumes:
  coder-home-data:
```

**Warning:** This approach has several important implications:

- It may conflict with the existing specific directory mounts
- It might cause permission issues if not properly initialized
- It will persist temporary files that might normally be cleared
- It can mask configuration issues that would be detected on clean start

For most use cases, it's better to persist specific directories rather than the entire home directory.

## Using Bind Mounts for Development

For active development, you might want to use bind mounts instead of named volumes to directly map directories from your host into the container:

```yaml
services:
  code-server:
    volumes:
      # Map a local directory to /home/coder/projects
      - ./my-projects:/home/coder/projects
      
      # Map dotfiles from your host
      - ~/.gitconfig:/home/coder/.gitconfig
      - ~/.ssh:/home/coder/.ssh:ro  # read-only for security
```

**Note:** When using bind mounts, be careful with file permissions. The files will be owned by your host user ID, which might differ from the `coder` user ID in the container.

## Initialization and Permissions

When adding new persistent directories, you may need to ensure they're properly initialized and have the correct permissions. The container's entrypoint script handles this for the default directories, but for custom directories, you'll need to handle permissions yourself.

The simplest approach is to run a one-time command to create directories and fix permissions after starting the container:

```bash
# Start the container with your custom volumes
COMPOSE_FILE=compose.yml:compose.override.yml docker compose up -d > docker-build.log 2>&1

# Run a command to create directories and fix permissions
docker compose exec code-server bash -c "
  # Create directories if they don't exist
  mkdir -p ~/custom-directory ~/projects ~/.dotfiles

  # Fix permissions
  sudo chown -R coder:coder ~/custom-directory
  sudo chown -R coder:coder ~/projects
  sudo chown -R coder:coder ~/.dotfiles
  
  echo 'Directories created and permissions fixed!'
" > permissions-fix.log 2>&1
```

This approach is cleaner than modifying the Dockerfile and allows you to make changes without rebuilding the container.

### Optional: Creating a Helper Script

For convenience, you can create a helper script on your host machine:

1. Create a file named `fix-permissions.sh`:

```bash
#!/bin/bash

# Define directories to initialize and fix permissions
DIRECTORIES=(
  "/home/coder/custom-directory"
  "/home/coder/projects"
  "/home/coder/.dotfiles"
  # Add more directories as needed
)

# Create directories and fix permissions
for DIR in "${DIRECTORIES[@]}"; do
  echo "Creating and fixing permissions for $DIR"
  mkdir -p "$DIR"
  sudo chown -R coder:coder "$DIR"
done

echo "All directories created and permissions fixed!"
```

2. Make it executable:

```bash
chmod +x fix-permissions.sh
```

3. Run it within the container when needed:

```bash
docker compose exec code-server bash -c "$(cat fix-permissions.sh)" > permissions-fix.log 2>&1
```

## Backing Up Persistent Data

To back up your persistent data, you can use Docker's volume backup features:

```bash
# List all volumes to identify what to back up
docker volume ls

# Back up a specific volume
docker run --rm -v vibe-station_custom-data:/source -v $(pwd):/backup alpine tar -czf /backup/custom-data-backup.tar.gz /source

# Restore a backed-up volume
docker run --rm -v vibe-station_custom-data:/target -v $(pwd):/backup alpine sh -c "rm -rf /target/* && tar -xzf /backup/custom-data-backup.tar.gz -C /target"
```

## Best Practices

1. **Be selective:** Only persist directories that contain important data that needs to survive container restarts.

2. **Use meaningful names:** Choose volume names that clearly indicate what data they contain.

3. **Document your customizations:** Keep a record of your custom persistence configuration.

4. **Regular backups:** Periodically back up important data volumes.

5. **Check permissions:** Ensure proper ownership and permissions on persistent directories.

6. **Volume cleanup:** Occasionally clean up unused volumes to free up disk space:
   ```bash
   docker volume prune -f
   ```