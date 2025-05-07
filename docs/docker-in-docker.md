# Docker-in-Docker (DinD) Configuration

This document explains the Docker-in-Docker (DinD) setup implemented in the vibe-station project.

## Overview

The vibe-station project implements Docker-in-Docker (DinD) to provide Docker capabilities to the code-server container. This setup uses the official Docker project's approach to ensure maximum compatibility and reliable operation across different environments.

Key benefits of this implementation:

1. **Resource limits support**: Proper functioning of CPU and memory limits when running containers inside the development environment.
2. **Enhanced compatibility**: Works reliably across different host systems including OrbStack on macOS.
3. **Official implementation**: Uses the exact scripts from the Docker and Moby projects to ensure proper compatibility and updates.
4. **Support for advanced features**: Properly sets up cgroups, mount propagation, and other Docker requirements.

## Implementation

The implementation follows the official Docker project's approach with scripts taken directly from the upstream Docker and Moby projects:

1. **dind script**: Sourced from the Moby project (https://github.com/moby/moby/blob/master/hack/dind)
   - Sets up cgroups v1 and v2 properly
   - Configures mount propagation
   - Sets up AppArmor integration
   - Handles security and namespace isolation

2. **dockerd-entrypoint.sh**: Sourced from the Docker project (https://github.com/docker-library/docker/blob/master/28/dind/dockerd-entrypoint.sh)
   - Handles TLS certificate generation when needed
   - Configures iptables (legacy or nftables as appropriate)
   - Sets up the Docker daemon with proper socket permissions
   - Supports both rootful and rootless operation

3. **entrypoint.sh**: Custom integration script
   - Ensures XDG directories exist with proper permissions
   - Sets up command history persistence
   - Starts the Docker daemon and monitors its health
   - Provides proper error reporting if startup fails

## Key Features

### cgroup Support

The implementation properly handles both cgroup v1 and v2 environments:

- **cgroup v2**: Sets up controller delegation properly
- **cgroup v1**: Works with traditional cgroup hierarchy

This ensures that resource limits (CPU, memory) function correctly when running containers inside the Docker-in-Docker environment.

### Mount Propagation

The implementation sets up proper mount propagation with:

```bash
# Change mount propagation to shared to make the environment more similar to a
# modern Linux system, e.g. with SystemD as PID 1.
mount --make-rshared /
```

This ensures that volume mounts work correctly between the host, the code-server container, and containers launched inside the Docker-in-Docker environment.

### Daemon Configuration

The Docker daemon is started with proper socket permissions and error handling:

```bash
# Start Docker daemon using official Docker-in-Docker approach
sudo /usr/local/bin/dockerd-entrypoint.sh > $DOCKER_LOG_FILE 2>&1 &
DOCKER_PID=$!

# Wait for Docker to become available
while [ $attempt -le $max_attempts ]; do
  if sudo chmod 666 /var/run/docker.sock 2>/dev/null && docker info > /dev/null 2>&1; then
    echo "Successfully started Docker daemon"
    return 0
  fi
  # ... error handling and retry logic ...
done
```

This ensures proper permissions and reliable startup with good error reporting if something goes wrong.

## OrbStack Compatibility

This implementation has been specifically tested and verified to work with OrbStack on macOS. The official Docker-in-Docker scripts handle the special environment characteristics of OrbStack correctly, including:

- Proper detection and configuration of cgroups
- Correct handling of mount propagation
- Working resource limits

## Security Considerations

While this setup is suitable for development, there are security considerations to be aware of:

1. **Privileged Mode**: The container must run in privileged mode to support Docker-in-Docker functionality.
2. **Root Access**: Docker requires root access for many operations.

For a more secure setup in production environments, consider:

1. Enabling TLS for Docker API communication by setting `DOCKER_TLS_CERTDIR`
2. Using a more restricted container runtime where possible
3. Implementing network policies to restrict access to the Docker API

## Troubleshooting

If you encounter issues with the DinD setup, try the following:

1. **Check Docker daemon logs**: Examine `/var/log/dockerd.log` inside the container for specific error messages.
2. **Verify cgroup setup**: Run `mount | grep cgroup` to ensure cgroups are properly mounted.
3. **Check socket permissions**: Run `ls -la /var/run/docker.sock` to verify socket permissions are set to `666`.
4. **Restart Docker daemon**: Sometimes completely restarting the Docker daemon with the entrypoint script can resolve issues.
5. **Reset Docker data**: If Docker storage becomes corrupted, you might need to remove and recreate the Docker data directory.

## Testing Resource Limits

To verify that resource limits are working correctly, you can run tests like:

```bash
# Test CPU limits
docker run --cpus 0.5 --rm -it alpine sh -c "while true; do echo 'testing CPU limits'; done"

# In another terminal, check that CPU usage is limited to approximately 50%
docker stats

# Test memory limits
docker run --memory 128m --rm -it alpine sh -c "dd if=/dev/zero of=/dev/null bs=1M"

# Watch memory usage stay within limits
docker stats
```

## References

- [Official Docker DinD script](https://github.com/moby/moby/blob/master/hack/dind)
- [Official Docker entrypoint script](https://github.com/docker-library/docker/blob/master/28/dind/dockerd-entrypoint.sh)
- [Docker documentation on resource constraints](https://docs.docker.com/config/containers/resource_constraints/)