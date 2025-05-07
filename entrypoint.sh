#!/bin/bash
set -e

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

# Setup for host Docker socket
configure_docker() {
  echo "Configuring access to host Docker socket..."
  
  # Wait for the Docker socket to be available
  if [ ! -S /var/run/docker.sock ]; then
    echo "Waiting for Docker socket from host..."
    max_attempts=15
    attempt=1
    
    while [ $attempt -le $max_attempts ]; do
      if [ -S /var/run/docker.sock ]; then
        echo "Docker socket detected"
        break
      fi
      
      echo "Attempt $attempt/$max_attempts: Docker socket not available yet, waiting..."
      attempt=$((attempt + 1))
      sleep 2
    done
    
    if [ ! -S /var/run/docker.sock ]; then
      echo "WARNING: Docker socket not found after $max_attempts attempts"
      echo "Docker functionality may not be available"
    fi
  fi
  
  # Verify Docker CLI can connect to the socket
  if [ -S /var/run/docker.sock ]; then
    echo "Testing Docker connection..."
    if docker info >/dev/null 2>&1; then
      echo "Successfully connected to Docker"
    else
      echo "WARNING: Docker socket is available but connection failed"
      echo "This might be due to permission issues or socket ownership"
    fi
  fi
}

# Run our setup tasks
ensure_xdg_dirs
configure_docker

# Run code-server and wait for it
# Check if any arguments were passed
if [ $# -eq 0 ]; then
  code-server --bind-addr 0.0.0.0:7080 --auth none --app-name vibe-station
else
  code-server "$@"
fi