# Testing

Assume we are on MacOS and have docker installed for now.

Be sure the nix code we are writing works by testing it in docker containers.

The project is using docker compose to speed up the process and cache the nix store
in a volume. Be sure it is running before running the tests.

For example, to use nixos containers to run tests, start the vibe-station-test container
with the following command:

```bash
docker compose up --build -d vibe-station
```

Then, run the tests with the following command:

```bash
docker compose exec vibe-station nix-shell \
  --extra-experimental-features "nix-command flakes" \
  --option filter-syscalls false \
  -p cowsay lolcat \
  --run "cowsay hello | lolcat"
```

