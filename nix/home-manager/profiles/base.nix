# Base profile: Essential tools and configurations
{
  config,
  pkgs,
  lib,
  ...
}: {
  # --- Custom Options ---
  options.vibe-station = {
    code-server = {
      settings = lib.mkOption {
        type = lib.types.attrs;
        default = {
          "workbench.colorTheme" = "Default Dark Modern";
          "terminal.integrated.defaultProfile.linux" = "zsh";
        };
        description = "Settings for code-server, applied to settings.json";
        example = lib.literalExpression ''
          {
            "workbench.colorTheme" = "GitHub Dark";
            "terminal.integrated.defaultProfile.linux" = "bash";
            "editor.fontSize" = 14;
          }
        '';
      };
    };
  };

  # --- Configuration ---
  config = {
    # --- Essential Packages ---
    home.packages = with pkgs; [
      # Version control
      git
      # gh # GitHub CLI (optional, uncomment if needed)

      # Containerization
      docker
      docker-compose
      # kubectl # Kubernetes CLI (optional, uncomment if needed)
      # helm # Kubernetes package manager (optional, uncomment if needed)

      # Development Tools
      code-server
      # nodejs # Latest Node.js (optional, uncomment if needed)
      # python3 # Latest Python 3 (optional, uncomment if needed)
      # go # Latest Go (optional, uncomment if needed)
      # rustup # Rust toolchain manager (optional, uncomment if needed)

      # Utilities
      curl
      wget
      jq # JSON processor
      yq # YAML processor
      btop # Process viewer
      ripgrep # Fast grep alternative
      fd # Fast find alternative
      bat # Cat clone with syntax highlighting
      tree # Directory listing tool
      unzip
      gnused # GNU sed implementation
      vim
      fzf
      # cowsay # Fun utility (for testing)
      # lolcat # Rainbow output (for testing)

      # Add other essential command-line tools here
    ];
    
    # --- Vibe Station Bin Directory ---
    # Create a bin directory for vibe station scripts and executables
    home.sessionPath = [ "$HOME/.vibe-station/bin" ];
    
    # Ensure the ~/.vibe-station/bin directory exists
    home.file.".vibe-station/bin/.keep".text = "";
    
    # Create the claude script directly in the home directory
    home.file.".vibe-station/bin/claude" = {
      text = ''
        #!/usr/bin/env nix-shell
        #! nix-shell -p nodejs_22 -i sh
        # shellcheck shell=sh
        mkdir -p ~/.config/local/claude
        export CLAUDE_CONFIG_DIR=~/.config/local/claude
        npx @anthropic-ai/claude-code "$@"
      '';
      executable = true;
    };

    # --- Program Configurations ---

    # Zsh Configuration
    programs.zsh = {
      enable = true;
      # Consider adding plugins via oh-my-zsh or other frameworks later
      # Example: enableAutosuggestions = true;
      shellAliases = {
        ls = "ls --color=auto";
        ll = "ls -alh";
        l = "ls -CF";
        ".." = "cd ..";
        "..." = "cd ../..";
        grep = "grep --color=auto";
        # Add more useful aliases
      };
      initContent = ''
        # Shell history persistence settings
        # Use /commandhistory volume for persistent history across container restarts
        
        # Ensure the directory exists
        if [ ! -d "/commandhistory" ]; then
          sudo mkdir -p /commandhistory
          sudo chown coder:coder /commandhistory
          sudo chmod 700 /commandhistory
        fi
        
        # Set history file to the volume
        export HISTFILE=/commandhistory/.zsh_history
        touch $HISTFILE
        chmod 600 $HISTFILE
        
        # Extensive history configuration
        HISTSIZE=10000
        SAVEHIST=10000
        setopt INC_APPEND_HISTORY    # Add commands to history as they are executed
        setopt SHARE_HISTORY         # Share history between all sessions
        setopt EXTENDED_HISTORY      # Save command timestamp
        setopt HIST_EXPIRE_DUPS_FIRST  # Expire duplicate entries first
        setopt HIST_IGNORE_DUPS      # Don't record an entry if it's a duplicate
        setopt HIST_FIND_NO_DUPS     # Don't show duplicates in search
        setopt HIST_IGNORE_SPACE     # Don't record entries starting with a space
        setopt HIST_SAVE_NO_DUPS     # Don't write duplicate entries
      '';
    };

    programs.fzf.enable = true;

    # Direnv Configuration (for project-specific environments)
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true; # Integrate with Nix flakes
    };

    # Git Configuration (minimal base settings, personal details in personal.nix)
    programs.git = {
      enable = true;
      # Set core editor in personal.nix or globally if preferred
      # extraConfig = {
      #   core.editor = "vim"; # Example
      # };
    };

    # Add configurations for other base programs here
    # Example:
    # programs.tmux = {
    #   enable = true;
    #   # configuration options...
    # };

    # --- Code-Server Configuration ---
    # Apply the code-server settings to the settings.json file
    home.file.".local/share/code-server/User/settings.json".text =
      builtins.toJSON config.vibe-station.code-server.settings;
  };
}
