# Testing

Assume we are on MacOS and have docker installed for now.

Be sure the nix code we are writing works by testing it in docker containers.

For example, to use nixos containers to run tests you'll likely need to use a command like
this:

```bash
# when running amd64, need to pass filter-syscalls=false
docker run --platform=linux/amd64 \
  -it \
  --rm \
  -v $PWD:/app \
  -w /app \
  nixos/nix \
  nix-shell  --extra-experimental-features "nix-command flakes" \
    --option filter-syscalls false \
    -p cowsay lolcat --run "cowsay hello | lolcat"
```

