# Personal profile: User-specific configurations and preferences
{
  config,
  pkgs,
  lib,
  ...
}: {
  # --- Configuration ---
  config = {
    # --- Personal Git Configuration ---
    # !! IMPORTANT: Customize these values !!
    programs.git = {
      # Assuming git is enabled in base.nix, we only add personal settings here
      userName = "Big Boss"; # Replace with your Git user name
      userEmail = "bigboss@metalrodeo.xyz"; # Replace with your Git email
      extraConfig = {
        # Example: Set preferred editor (overrides any base setting if desired)
        core.editor = "vim"; # Or "code --wait", "nvim", etc.
        # Example: Configure pull behavior
        pull.rebase = false; # Or true if you prefer rebasing
        # Add other personal Git settings
        # init.defaultBranch = "main";
      };
      # signing = {
      #   key = "YOUR_GPG_KEY_ID"; # Uncomment and set if you use GPG signing
      #   signByDefault = true;
      # };
    };

    # --- Personal Shell Customizations ---
    programs.zsh = {
      # Assuming zsh is enabled in base.nix
      # Add personal aliases or functions here
      shellAliases = {
        # Example personal alias
        # update-system = "sudo nixos-rebuild switch --flake /etc/nixos#yourhostname";
      };
      # Add environment variables or custom init commands
      # initExtra = ''
      #   # Example: Add personal bin directory to PATH
      #   # export PATH="$HOME/.local/bin:$PATH"

      #   # Add any other personal shell startup commands here
      #   # Maybe load a custom theme or plugins if not using a framework managed by HM
      # '';
      # If using Oh My Zsh managed by Home Manager:
      oh-my-zsh = {
        enable = true;
        plugins = ["git" "docker"]; # Add desired plugins
        theme = "ys"; # Set desired theme
      };
    };

    # --- Other Personal Program Configurations ---
    # Example: Personal Neovim settings (if nvim is enabled elsewhere)
    # programs.neovim = {
    #   extraConfig = ''
    #     lua << EOF
    #     -- Your personal Lua config here
    #     vim.opt.relativenumber = true
    #     EOF
    #   '';
    # };

    # Add configurations for other personal tools or preferences
  };
}
