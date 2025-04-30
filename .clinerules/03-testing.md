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
docker compose up --build -d code-server
```

Then, run the tests with the following command:

```bash
docker compose exec code-server nix-shell \
  -p cowsay lolcat \
  --run "cowsay hello | lolcat"
```

Sometimes the nix image gets updated and we need reset the volume to repair the /nix/store.

```bash
docker compose down -v
docker compose up --build -d code-server
```
