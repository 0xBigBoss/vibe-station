#!/bin/bash

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
code-server "$@"

# When using host Docker, we don't need to clean up the daemon
if [ "$USING_HOST_DOCKER" != "true" ]; then
  # When code-server exits, the script will continue
  # and the EXIT trap will run, cleaning up Docker
  echo "Exiting..."
fi
