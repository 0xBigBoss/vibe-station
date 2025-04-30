FROM debian:bookworm

RUN apt update \
  && apt install -y curl xz-utils \
  && /sbin/useradd -m coder \
  && mkdir -p /home/coder/.local/share/code-server \
  && chown -R coder /home/coder \
  && mkdir /nix \
  && chown coder /nix \
  && mkdir -p /etc/nix \
  && chown coder /etc/nix \
  && apt clean

USER coder
ENV USER=coder
ENV PATH="/home/coder/.nix-profile/bin:${PATH}"
RUN curl -sL https://nixos.org/nix/install | sh -s -- --no-daemon

# Enable experimental features and custom options in the container's nix.conf
RUN echo 'experimental-features = nix-command flakes' >> /etc/nix/nix.conf && \
  echo 'filter-syscalls = false' >> /etc/nix/nix.conf

USER coder

# Install required packages
RUN nix-env -iA nixpkgs.code-server nixpkgs.home-manager

# Expose port 7080 for code-server
EXPOSE 7080

# Start the code-server container
CMD ["code-server", "--bind-addr", "0.0.0.0:7080", "--auth", "none"]
