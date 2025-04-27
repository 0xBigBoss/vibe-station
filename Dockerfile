FROM nixos/nix:latest

# Enable experimental features and custom options in the container's nix.conf
RUN mkdir -p /etc/nix && \
  echo 'experimental-features = nix-command flakes' >> /etc/nix/nix.conf && \
  echo 'filter-syscalls = false' >> /etc/nix/nix.conf

# Install the code-server package
RUN nix-env -iA nixpkgs.code-server

# Expose port 7080 for code-server
EXPOSE 7080

# Start the code-server container
CMD ["code-server", "--bind-addr", "0.0.0.0:7080", "--auth", "none"]
