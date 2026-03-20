# Headless-specific nvim setup (non-interactive)
# The omarchy-nvim package installs the config, but we need to set up the theme link
# Remove existing config first to avoid interactive confirmation, then run setup

# Ensure USER is set (not set in Docker containers)
export USER="${USER:-$(id -un)}"

if [[ -d ~/.config/nvim ]]; then
  rm -rf ~/.config/nvim
fi

# Run setup but ignore xdg-mime errors (GUI utility not available headless)
omarchy-nvim-setup 2>/dev/null || true
