#!/bin/bash
# Start Docker daemon
sudo dockerd &
DOCKER_PID=$!

# Function to handle shutdown
cleanup() {
  echo "Shutting down Docker daemon"
  sudo kill $DOCKER_PID
  wait $DOCKER_PID
  echo "Docker daemon stopped"
  exit 0
}

# Register the cleanup function for SIGTERM
trap cleanup SIGTERM

# Wait for Docker daemon to start
echo "Waiting for Docker daemon to start..."
until sudo docker info >/dev/null 2>&1; do
  sleep 1
done
echo "Docker daemon started"

# Run code-server in the background with passed arguments
code-server "$@" &
CODE_SERVER_PID=$!

# Wait for any process to exit
wait $CODE_SERVER_PID
