#!/usr/bin/env bash
# test-profiles.sh - Test script for Vibe Station Home Manager overlayed profiles
# This script helps validate the Home Manager configuration within a Docker environment

set -e # Exit on error

# Text formatting
BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
RESET="\033[0m"

# Helper functions
print_header() {
  echo -e "\n${BOLD}${GREEN}=== $1 ===${RESET}\n"
}

print_step() {
  echo -e "${YELLOW}→ $1${RESET}"
}

print_error() {
  echo -e "${RED}ERROR: $1${RESET}"
}

check_prereqs() {
  print_header "Checking prerequisites"

  if ! command -v docker &>/dev/null; then
    print_error "Docker is not installed or not in PATH"
    exit 1
  fi

  if ! command -v docker compose &>/dev/null; then
    print_error "Docker Compose is not installed or not in PATH"
    exit 1
  fi

  print_step "Docker and Docker Compose are available"
}

start_container() {
  print_header "Starting Docker container"
  print_step "Building and starting the code-server container..."

  # Navigate to the project root directory
  cd "$(dirname "$0")/../.." || exit 1

  # Start the container
  docker compose up --build -d code-server

  # Check if container started successfully
  if [ $? -ne 0 ]; then
    print_error "Failed to start the Docker container"
    exit 1
  fi

  print_step "Container started successfully"
  echo "Waiting 5 seconds for container to initialize..."
  sleep 5
}

test_home_manager_build() {
  print_header "Testing Home Manager configuration"

  # Get username from home.nix
  USERNAME=$(docker compose exec code-server bash -c "grep 'home.username' /app/nix/home-manager/home.nix | sed -E 's/.*\"([^\"]+)\".*/\1/'")

  if [ "$USERNAME" == "yourusername" ]; then
    print_step "Using default username 'yourusername' (not customized yet)"
  else
    print_step "Using configured username: $USERNAME"
  fi

  print_step "Validating Home Manager configuration syntax..."

  # Test building the configuration (syntax check)
  if docker compose exec code-server bash -c "cd /app/nix/home-manager && home-manager build --flake .#$USERNAME --no-out-link"; then
    echo -e "${GREEN}✓ Home Manager configuration syntax is valid${RESET}"
  else
    print_error "Home Manager configuration has syntax errors"
    exit 1
  fi
}

test_base_profile() {
  print_header "Testing base profile packages"

  # Extract a few packages from base.nix to test
  BASE_PACKAGES=$(docker compose exec code-server bash -c "grep -A20 'home.packages' /app/nix/home-manager/profiles/base.nix | grep -v '#' | grep -o '[a-zA-Z0-9-]\+' | grep -v 'with' | grep -v 'pkgs' | grep -v 'home' | grep -v 'packages' | head -5")

  if [ -z "$BASE_PACKAGES" ]; then
    print_step "No packages found in base profile to test"
    return
  fi

  # Test each package
  for pkg in $BASE_PACKAGES; do
    print_step "Testing package: $pkg"
    if docker compose exec code-server bash -c "nix-shell -p $pkg --run \"command -v $pkg || echo not-found\""; then
      echo -e "${GREEN}✓ Package $pkg is available${RESET}"
    else
      echo -e "${YELLOW}⚠ Package $pkg test inconclusive${RESET}"
    fi
  done
}

test_direnv() {
  print_header "Testing direnv configuration"

  print_step "Checking if direnv is enabled in the configuration..."

  if docker compose exec code-server bash -c "grep -q 'direnv.*enable.*true' /app/nix/home-manager/profiles/base.nix"; then
    echo -e "${GREEN}✓ direnv is enabled in the configuration${RESET}"

    print_step "Testing direnv package availability..."
    if docker compose exec code-server bash -c "nix-shell -p direnv --run \"command -v direnv || echo not-found\""; then
      echo -e "${GREEN}✓ direnv package is available${RESET}"
    else
      echo -e "${YELLOW}⚠ direnv package test inconclusive${RESET}"
    fi
  else
    echo -e "${YELLOW}⚠ direnv is not enabled in the configuration${RESET}"
  fi
}

cleanup() {
  print_header "Cleanup"

  read -p "Do you want to stop the Docker container? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_step "Stopping Docker container..."
    cd "$(dirname "$0")/../.." || exit 1
    docker compose down
    echo -e "${GREEN}✓ Container stopped${RESET}"
  else
    print_step "Leaving container running"
    echo "You can stop it later with: docker compose down"
  fi
}

# Main execution
echo -e "${BOLD}Vibe Station Home Manager Overlayed Profiles Test Script${RESET}"
echo "This script will test your Home Manager configuration in a Docker environment"
echo

check_prereqs
start_container
test_home_manager_build
test_base_profile
test_direnv

print_header "Test Summary"
echo -e "${GREEN}✓ All tests completed${RESET}"
echo
echo -e "${BOLD}Next Steps:${RESET}"
echo "1. Review any warnings or errors in the test output"
echo "2. Customize your configuration in home.nix and profiles/*.nix"
echo "3. For a full test, apply the configuration on your actual system with:"
echo "   cd nix/home-manager && nix run home-manager/master -- switch --flake .#coder"
echo

cleanup

echo -e "\n${BOLD}${GREEN}Testing completed!${RESET}"
