#!/bin/bash
# Test script for verifying locale fix in Docker container

# Build the updated Docker image with locale fix
echo "Building Docker image with locale fixes..."
docker compose build > build-log.txt 2>&1

# Start the container
echo "Starting the container..."
docker compose up -d > startup-log.txt 2>&1

# Test locale settings
echo "Testing locale settings..."
docker compose exec code-server bash -c "locale" > locale-test.txt 2>&1

# Check if warning still appears
echo "Checking for locale warnings..."
docker compose exec code-server bash -c "echo 'Test command'" > warning-test.txt 2>&1

echo "Tests complete. Check locale-test.txt and warning-test.txt for results."
echo "To stop the container: docker compose down"