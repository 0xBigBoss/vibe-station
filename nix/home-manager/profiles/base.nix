# Base profile: Essential tools and configurations
{
  config,
  pkgs,
  lib,
  ...
}: {
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
    # cowsay # Fun utility (for testing)
    # lolcat # Rainbow output (for testing)

    # Add other essential command-line tools here
  ];

  # --- Program Configurations ---

  # Docker Configuration
  # This ensures Docker uses the mounted volume for storing images
  home.file.".docker/config.json".text = ''
    {
      "data-root": "/var/lib/docker"
    }
  '';

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
    # initExtra = ''
    #   # Custom Zsh settings can go here
    # '';
  };

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
}
