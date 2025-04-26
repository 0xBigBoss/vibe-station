FROM nixos/nix:latest

# Enable experimental features and custom options in the container's nix.conf
RUN mkdir -p /etc/nix && \
  echo 'experimental-features = nix-command flakes' >> /etc/nix/nix.conf && \
  echo 'filter-syscalls = false' >> /etc/nix/nix.conf
