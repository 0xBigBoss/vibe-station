# Docker and Home Manager Enhancements

## Tasks

1. ✅ **Passwordless Sudo for Coder User** (Completed)
   - Patch the Debian container so that the `coder` user has passwordless sudo working correctly
   - Add necessary configuration to `/etc/sudoers.d/` to grant the `coder` user passwordless sudo privileges
   - Implementation: Added `echo "coder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/coder` to Dockerfile
   - Tested and confirmed working after running `docker compose down -v` and `docker compose up -d`

2. ✅ **Home Manager Switch in Dockerfile** (Completed)
   - Add the home manager switch step to the Dockerfile
   - Apply the base configuration during image build
   - Ensure proper execution order and permissions
   - Implementation: Added steps to copy home-manager directory and run `nix run github:nix-community/home-manager -- switch --flake`
   - Tested and confirmed working with:
     - home-manager installed and working (version 25.05-pre)
     - zsh installed in the expected location
     - Essential packages from the base profile (git, curl, jq) installed
     - Docker configuration file created correctly
     - oh-my-zsh installed correctly

3. **Parameterize App Directory**
   - Parameterize the `/app` directory in the Dockerfile using an ENV variable
   - Make the mount point configurable for different use cases
   - Update relevant scripts and configurations to use this variable

4. **Code-Server Settings Configuration**
   - Create a Home Manager option to configure `code-server` settings
   - Allow setting the theme and default terminal profile
   - Target configuration file: `/home/coder/.local/share/code-server/User/settings.json`
   - Default settings:
     ```json
     {
         "workbench.colorTheme": "Default Dark Modern",
         "terminal.integrated.defaultProfile.linux": "zsh"
     }
     ```

5. **Documentation Updates**
   - Update documentation to reflect the Dockerfile changes
   - Document the new Home Manager option for code-server settings
   - Provide examples of customizing the settings
