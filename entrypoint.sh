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

# Start Docker daemon
start_docker() {
  echo "Starting Docker daemon with resource limits support..."
  
  # Ensure docker data directory exists
  sudo mkdir -p /var/lib/docker
  sudo chown -R root:root /var/lib/docker
  
  # Clean up any existing docker socket
  sudo rm -f /var/run/docker.sock
  
  # Stop any existing Docker service if running
  if systemctl is-active --quiet docker 2>/dev/null; then
    echo "Docker service is already running, stopping it first..."
    sudo systemctl stop docker containerd
  fi
  
  # Start Docker daemon using official Docker-in-Docker approach
  echo "Starting Docker daemon using official Docker-in-Docker approach..."
  DOCKER_LOG_FILE="/var/log/dockerd.log"
  # Create log file with correct permissions
  sudo touch $DOCKER_LOG_FILE
  sudo chown coder:coder $DOCKER_LOG_FILE
  sudo /usr/local/bin/dockerd-entrypoint.sh > $DOCKER_LOG_FILE 2>&1 &
  DOCKER_PID=$!
  
  # Wait for Docker to become available
  echo "Waiting for Docker daemon to start..."
  max_attempts=30
  attempt=1
  
  while [ $attempt -le $max_attempts ]; do
    if sudo chmod 666 /var/run/docker.sock 2>/dev/null && docker info > /dev/null 2>&1; then
      echo "Successfully started Docker daemon"
      return 0
    fi
    
    # Check if dockerd process is still running
    if ! kill -0 $DOCKER_PID 2>/dev/null; then
      echo "ERROR: Docker daemon process died unexpectedly"
      echo "--- Last 50 lines of Docker daemon log ---"
      tail -n 50 $DOCKER_LOG_FILE
      return 1
    fi
    
    echo "Attempt $attempt/$max_attempts: Docker daemon not available yet, waiting..."
    attempt=$((attempt + 1))
    sleep 2
  done
  
  echo "ERROR: Failed to start Docker daemon after $max_attempts attempts"
  echo "--- Last 50 lines of Docker daemon log ---"
  tail -n 50 $DOCKER_LOG_FILE
  return 1
}

# Run our setup tasks
ensure_xdg_dirs

# Start Docker daemon with retries and better error handling
start_docker || {
  echo "ERROR: Failed to start Docker daemon during container initialization"
  exit 1
}

# Run code-server and wait for it
# Check if any arguments were passed
if [ $# -eq 0 ]; then
  code-server --bind-addr 0.0.0.0:7080 --auth none --app-name vibe-station
else
  code-server "$@"
fi