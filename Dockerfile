FROM debian:bookworm

RUN apt update \
  && apt install -y curl xz-utils sudo \
  && /sbin/useradd -m coder \
  && mkdir -p /home/coder/.local/share/code-server \
  && chown -R coder /home/coder \
  && mkdir /nix \
  && chown coder /nix \
  && mkdir -p /etc/nix \
  && chown coder /etc/nix \
  && mkdir -p /etc/sudoers.d \
  && echo "coder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/coder \
  && chmod 440 /etc/sudoers.d/coder \
  && apt clean

USER coder
ENV USER=coder
ENV PATH="/home/coder/.nix-profile/bin:${PATH}"
RUN curl -sL https://nixos.org/nix/install | sh -s -- --no-daemon

# Enable experimental features and custom options in the container's nix.conf
RUN echo 'experimental-features = nix-command flakes' >> /etc/nix/nix.conf && \
  echo 'filter-syscalls = false' >> /etc/nix/nix.conf

USER coder

# Install home-manager and apply base configuration
WORKDIR /tmp/vibe-station
COPY --chown=coder:coder ./nix/home-manager /tmp/vibe-station/nix/home-manager
RUN nix run github:nix-community/home-manager -- switch --flake /tmp/vibe-station/nix/home-manager#coder && \
  rm -rf /tmp/vibe-station

WORKDIR /app

# Expose port 7080 for code-server
EXPOSE 7080

# Start the code-server container
CMD ["code-server", "--bind-addr", "0.0.0.0:7080", "--auth", "none"]
