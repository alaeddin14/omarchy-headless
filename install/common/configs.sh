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
  
  echo "✅ Bash configuration complete"
  echo "  Note: Run 'source ~/.bashrc' or start a new shell to apply"
}
