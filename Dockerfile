FROM debian:bookworm

# Install dependencies including Docker
RUN apt update \
  && apt install -y curl xz-utils sudo apt-transport-https ca-certificates gnupg lsb-release \
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
  # Install Docker
  && install -m 0755 -d /etc/apt/keyrings \
  && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
  && chmod a+r /etc/apt/keyrings/docker.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
  && apt update \
  && apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
  # Create Docker group and add coder user to it
  && groupadd -f docker \
  && usermod -aG docker coder \
  && mkdir -p /etc/docker \
  # Configure Docker daemon for DinD
  && echo '{ "storage-driver": "vfs" }' > /etc/docker/daemon.json \
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

# Create a wrapper script to start Docker and then code-server
COPY --chown=coder:coder entrypoint.sh /home/coder/entrypoint.sh
RUN sudo chmod +x /home/coder/entrypoint.sh

# Start Docker daemon and then code-server
ENTRYPOINT ["/home/coder/entrypoint.sh"]
