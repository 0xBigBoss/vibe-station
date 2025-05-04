#!/bin/bash

# Ensure XDG directories exist with proper permissions
ensure_xdg_dirs() {
  echo "Ensuring XDG directories exist with proper permissions..."
  
  # Standard XDG Base Directories
  mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"
  mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}"
  mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}"
  mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}"
  
  # Fix any permission issues that might arise from volume mounts
  sudo chown -R coder:coder "${XDG_CONFIG_HOME:-$HOME/.config}"
  sudo chown -R coder:coder "${XDG_DATA_HOME:-$HOME/.local/share}"
  sudo chown -R coder:coder "${XDG_STATE_HOME:-$HOME/.local/state}"
  sudo chown -R coder:coder "${XDG_CACHE_HOME:-$HOME/.cache}"
  sudo chown -R coder:coder "$HOME/.nix-profile" 2>/dev/null || true
  
  # Set up command history persistence
  if [ -d "/commandhistory" ]; then
    echo "Setting up shell history persistence..."
    sudo mkdir -p /commandhistory
    sudo chown -R coder:coder /commandhistory
    sudo chmod 700 /commandhistory
    touch /commandhistory/.zsh_history 2>/dev/null || true
    chmod 600 /commandhistory/.zsh_history 2>/dev/null || true
  fi
}

# Run our setup tasks
ensure_xdg_dirs

# Check if Docker socket is mounted from host
if [ -S /var/run/docker.sock ] && docker info >/dev/null 2>&1; then
  echo "Host Docker engine detected at /var/run/docker.sock, skipping local Docker daemon startup"
  USING_HOST_DOCKER=true
else
  echo "No host Docker engine detected, starting local Docker daemon..."
  sudo dockerd &
  DOCKER_PID=$!

  # Function to handle shutdown of Docker daemon
  stop_docker() {
    echo "Shutting down Docker daemon..."
    sudo kill -TERM "$DOCKER_PID"
    wait "$DOCKER_PID"
    echo "Docker daemon stopped"
  }

  # Register the cleanup function to run at script exit
  trap stop_docker EXIT SIGINT SIGTERM
fi

# Run code-server and wait for it
# Check if any arguments were passed
if [ $# -eq 0 ]; then
  code-server --bind-addr 0.0.0.0:7080 --auth none --app-name vibe-station
else
  code-server "$@"
fi

# When using host Docker, we don't need to clean up the daemon
if [ "$USING_HOST_DOCKER" != "true" ]; then
  # When code-server exits, the script will continue
  # and the EXIT trap will run, cleaning up Docker
  echo "Exiting..."
fi
