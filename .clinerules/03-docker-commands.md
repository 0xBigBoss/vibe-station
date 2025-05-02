# Docker

When working with Docker in this project:

- Use the Dockerfile and compose.yml files in the root directory
- Refer to docs/running-with-docker.md for instructions on how to use Docker with this project
- **IMPORTANT**: Always follow the guidelines to prevent context window overflow
- **NEVER** run Docker build or compose commands in the terminal without output redirection or quiet flags

## Docker Command Best Practices

When working with Docker in this project, follow these guidelines to maintain an efficient workflow and prevent context window overflow.

### 1. ALWAYS Redirect Output for Build Commands

Docker build and compose commands often produce extensive output that can quickly fill up the context window. **ALWAYS** redirect the output to a log file or use quiet flags:

```bash
# REQUIRED: Redirect output to a log file
docker compose up --build -d > docker-build.log 2>&1

# REQUIRED: Use quiet flags when available
docker compose up --build -d --quiet-pull

# REQUIRED: Combine both approaches for maximum verbosity reduction
docker compose up --build -d --quiet-pull > docker-build.log 2>&1
```

### 2. Testing Docker Builds

When testing Docker builds, especially those that involve Nix operations:

```bash
# Reset volumes before testing major changes
docker compose down -v

# REQUIRED: Use quiet flags and/or redirect output
docker compose up --build -d --quiet-pull > docker-build.log 2>&1
```

### 3. Executing Commands in Docker Containers

When running commands in Docker containers:

```bash
# For simple commands with minimal output
docker compose exec container_name simple_command

# REQUIRED: For commands with extensive output
docker compose exec container_name complex_command > command-output.log 2>&1
```

>[!IMPORTANT]
> Be aware that you may need to escape special characters in the command, such as `$` or `>`, when using redirection inside the container. Otherwise, the characters will be interpreted by the shell on the host machine.

### 4. Checking Build Results

After building with redirected output, check the status:

```bash
# Check if containers are running
docker compose ps

# Check logs for specific containers (limit output)
docker compose logs --tail=20 container_name
```

## Home Manager in Docker

When working with Home Manager in Docker:

1. **Initial activation** should use `nix run` with output redirection:
   ```bash
   # REQUIRED: Redirect output to a log file
   docker compose exec code-server bash -c "cd /app/nix/home-manager && nix run github:nix-community/home-manager -- switch --flake .#coder" > home-manager-activation.log 2>&1
   ```

2. **Subsequent activations** can use the standard command with output redirection:
   ```bash
   # REQUIRED: Redirect output to a log file
   docker compose exec code-server bash -c "cd /app/nix/home-manager && home-manager switch --flake .#coder" > home-manager-switch.log 2>&1
   ```

## IMPORTANT: Context Window Management

The context window is a limited resource. Docker and Nix commands can produce thousands of lines of output that consume this resource unnecessarily. Always follow these rules:

1. **NEVER** run Docker build or compose commands without output redirection or quiet flags
2. **ALWAYS** use `--quiet-pull` when pulling images
3. **ALWAYS** redirect output for commands that involve Nix operations
4. **PREFER** checking container status with `docker compose ps` rather than watching the build output

Remember: Filling the context window with build output prevents effective communication and problem-solving. When in doubt, redirect output to a log file.
