#!/bin/bash
# Common configuration installation (all distros)

install_common_configs() {
  local omarchy_path="${1:-$HOME/.local/share/omarchy}"
  
  echo "⚙️  Installing configurations..."
  
  # Create config directory
  mkdir -p ~/.config
  
  # Copy headless-safe configs
  local configs_to_copy=(
    "git"
    "btop"
    "lazygit"
    "tmux"
    "opencode"
    "elephant"
    "environment.d"
    "omarchy"
  )
  
  for config in "${configs_to_copy[@]}"; do
    if [[ -d "$omarchy_path/config/$config" ]]; then
      echo "  Copying config: $config"
      cp -r "$omarchy_path/config/$config" ~/.config/
    fi
  done
  
  # Copy single files
  if [[ -f "$omarchy_path/config/starship.toml" ]]; then
    echo "  Copying starship.toml"
    cp "$omarchy_path/config/starship.toml" ~/.config/
  fi
  
  if [[ -f "$omarchy_path/config/fastfetch/config.jsonc" ]]; then
    echo "  Copying fastfetch config"
    mkdir -p ~/.config/fastfetch
    cp "$omarchy_path/config/fastfetch/config.jsonc" ~/.config/fastfetch/
  fi
  
  echo "✅ Configurations installed"
}

install_bash_config() {
  local omarchy_path="${1:-$HOME/.local/share/omarchy}"
  
  echo "⚙️  Setting up bash configuration..."
  
  # Create headless marker file for migration runner
  if [[ -n $OMARCHY_HEADLESS ]]; then
    mkdir -p ~/.local/state/omarchy
    touch ~/.local/state/omarchy/headless
    echo "  Marked installation as headless"
  fi
  
  # Create ~/.local/bin directory and env file for PATH setup
  echo "  Creating ~/.local/bin and env file..."
  mkdir -p ~/.local/bin
  
  # Create the env file that adds omarchy binaries to PATH
  # This file is sourced by .bashrc
  cat > ~/.local/bin/env << 'EOF'
#!/bin/sh
# Add binaries to PATH if they aren't added yet
# affix colons on either side of $PATH to simplify matching
case ":${PATH}:" in
    *:"$HOME/.local/share/omarchy/bin":*)
        ;;
    *)
        # Prepending path so omarchy binaries are found
        export PATH="$HOME/.local/share/omarchy/bin:$PATH"
        ;;
esac

# Also ensure ~/.local/bin is in PATH
case ":${PATH}:" in
    *:"$HOME/.local/bin":*)
        ;;
    *)
        export PATH="$HOME/.local/bin:$PATH"
        ;;
esac
EOF
  chmod +x ~/.local/bin/env
  echo "  Created ~/.local/bin/env"
  
  # Backup existing bashrc
  if [[ -f ~/.bashrc ]]; then
    cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d%H%M%S)
    echo "  Backed up existing ~/.bashrc"
  fi
  
  # Use Omarchy bashrc
  if [[ -f "$omarchy_path/default/bashrc" ]]; then
    cp "$omarchy_path/default/bashrc" ~/.bashrc
    echo "  Installed Omarchy bashrc"
  fi
  
  # Ensure the env file is sourced in .bashrc (for headless compatibility)
  if ! grep -q 'source.*\.local/bin/env' ~/.bashrc 2>/dev/null && ! grep -q '\.\s*"\$HOME/.local/bin/env"' ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    echo "# Source local env file for PATH setup" >> ~/.bashrc
    echo '[[ -f ~/.local/bin/env ]] && . ~/.local/bin/env' >> ~/.bashrc
    echo "  Added env file source to .bashrc"
  fi
  
  echo "✅ Bash configuration complete"
  echo "  Note: Run 'source ~/.bashrc' or start a new shell to apply"
}
