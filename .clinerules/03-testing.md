# Testing

Assume we are on MacOS and have docker installed for now.

Be sure the nix code we are writing works by testing it in docker containers.

The project is using a Debian-based Docker image with Nix installed in single-user mode,
allowing us to run as a non-root user while still having full Nix functionality.

The project is using docker compose to speed up the process and cache the nix store
in a volume. Be sure it is running before running the tests.

For example, to use nixos containers to run tests, start the code-server-test container
with the following command:

```bash
# Use -d flag to run in detached mode (background)
# Add --quiet-pull to reduce output when pulling images
docker compose up --build -d code-server

# Alternatively, redirect verbose output to a log file
# docker compose up --build -d code-server > docker-build.log 2>&1
```

Then, run the tests with the following command:

```bash
# For commands with minimal output
docker compose exec code-server nix-shell \
  -p cowsay lolcat \
  --run "cowsay hello | lolcat"

# For commands with verbose output, redirect to a log file
# docker compose exec code-server nix-shell \
#   -p some-package \
#   --run "verbose-command" > command-output.log 2>&1
```

Sometimes the nix image gets updated and we need reset the volume to repair the /nix/store.

```bash
# Reset the volumes
docker compose down -v

# Restart with reduced output
docker compose up --build -d code-server --quiet-pull

# Or redirect output to a log file
# docker compose up --build -d code-server > docker-rebuild.log 2>&1
```

## Managing Command Output

When running commands that produce extensive output (like Nix builds or Docker operations):

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

This helps prevent filling up the context window with verbose command output.
