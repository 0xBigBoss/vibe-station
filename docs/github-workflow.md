# GitHub Workflow for Docker Build and Push

This document describes the GitHub Actions workflow that builds and pushes the vibe-station Docker image to GitHub Container Registry (GHCR).

## Workflow Overview

The workflow is defined in `.github/workflows/docker-build-push.yml` and performs the following actions:

1. Builds the Docker image using the Dockerfile in the repository
2. Tags the image appropriately based on the trigger (branch, tag, PR)
3. Pushes the image to GitHub Container Registry (except for pull requests)

## Triggers

The workflow is triggered on:

- **Push to master**: When changes are pushed to the `master` branch that affect:
  - `Dockerfile`
  - `entrypoint.sh`
  - Any files in the `nix/home-manager` directory
  - The workflow file itself

- **Pull Requests to master**: When PRs are opened or updated that affect the same files

- **Release**: When a new release is published in GitHub

- **Manual Trigger**: The workflow can be manually triggered from the GitHub Actions UI

## Image Tags

The workflow creates multiple tags to identify different versions of the image:

- Branch name (e.g., `master`)
- PR number for pull requests
- Semantic versioning tags for releases (e.g., `1.0.0`, `1.0`)
- Git SHA for precise version identification
- `latest` tag for the default branch (master)

## Authentication

The workflow uses the built-in `GITHUB_TOKEN` for authentication to the GitHub Container Registry. No additional secrets or manual setup is required for this to work.

## Build Optimizations

The workflow uses Docker Buildx with GitHub Actions cache to speed up builds:

- **Cache-from and Cache-to**: Reuses layers from previous builds
- **Platform Specification**: Currently builds for `linux/amd64` only

## How to Use the Published Images

Once built and pushed, you can pull the Docker image from GitHub Container Registry:

```bash
docker pull ghcr.io/OWNER/vibe-station:tag
```

Replace:
- `OWNER` with your GitHub username or organization
- `tag` with the desired version tag (e.g., `latest`, `1.0.0`)

## Troubleshooting

If the workflow fails, check:

1. The GitHub Actions log for specific error messages
2. That the repository has proper permissions for GitHub Packages
3. That the Dockerfile builds successfully locally

## Local Testing

To test the build process locally before pushing:

```bash
docker build -t vibe-station:test .
```

To run the image locally:

```bash
docker run -p 7080:7080 vibe-station:test
```