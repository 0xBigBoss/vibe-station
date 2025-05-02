# User Data Persistence Plan

This document outlines the strategy for persisting user data in the vibe-station container, especially for agents that use XDG directories.

## XDG Directory Overview

XDG Base Directory Specification defines standard locations for user data:

- `XDG_CONFIG_HOME` (~/.config): Application configuration files
- `XDG_DATA_HOME` (~/.local/share): Application data files
- `XDG_STATE_HOME` (~/.local/state): Application state information
- `XDG_CACHE_HOME` (~/.cache): Non-essential cached data

## Current Status

The vibe-station Docker setup currently persists:
- `/nix` (Nix store)
- `/home/coder/.local/share/code-server` (Code Server data)
- Docker images data

However, many other user directories that might contain important data are not persisted.

## Implementation Plan

### 1. Persist All XDG Standard Directories

Add the following volume mounts to the Docker Compose configuration:

```yaml
volumes:
  - coder-config-data:/home/coder/.config
  - coder-local-data:/home/coder/.local
  - coder-cache-data:/home/coder/.cache
```

And add corresponding volume definitions:

```yaml
volumes:
  coder-config-data:
  coder-local-data:
  coder-cache-data:
```

### 2. Persist Home Manager State

Ensure Home Manager state is persisted by mounting:

```yaml
  - coder-nix-profile:/home/coder/.nix-profile
```

### 3. Additional Persistence for Common Tools

Add persistence for additional common tool directories:

```yaml
  - coder-home-data:/home/coder
```

This will capture all dotfiles and configuration in the home directory.

### 4. Container Initialization Script

Modify the entrypoint script to:
1. Set up proper XDG environment variables if not defined
2. Ensure proper permissions on mounted volumes
3. Initialize default configuration for common tools if not present

### Implementation Notes

- We'll use named volumes instead of bind mounts to ensure data stays with the container
- Consider backup procedures for these volumes
- Document the persistence strategy for users

## Customizing Data Persistence

For a detailed guide on how to add custom persistent directories or customize the data persistence strategy, see [Customizing Data Persistence](customizing-data-persistence.md).