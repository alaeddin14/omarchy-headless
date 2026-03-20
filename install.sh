#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -eEo pipefail

# Define Omarchy locations
export OMARCHY_PATH="${OMARCHY_PATH:-$HOME/.local/share/omarchy}"
export OMARCHY_INSTALL="$OMARCHY_PATH/install"
export PATH="$OMARCHY_PATH/bin:$PATH"

# Detect distro
source "$OMARCHY_INSTALL/detect-distro.sh"
OMARCHY_DISTRO=$(detect_distro)

echo "🔍 Detected distribution: $OMARCHY_DISTRO"

# Source distro-specific implementation
case $OMARCHY_DISTRO in
  arch)
    source "$OMARCHY_INSTALL/distros/arch/packages.sh"
    ;;
  debian)
    echo "⚠️  Debian support coming in Phase 2"
    echo "For now, this only supports Arch Linux"
    exit 1
    ;;
  *)
    echo "❌ Unsupported distribution: $OMARCHY_DISTRO"
    echo "Currently supported: arch"
    exit 1
    ;;
esac

# Install packages for detected distro
echo "📦 Installing packages..."
case $OMARCHY_DISTRO in
  arch)
    install_arch_packages "$OMARCHY_INSTALL"
    ;;
esac

# Define run_logged function before using it
run_logged() {
  local script="$1"
  echo "  Running: $(basename "$script")"
  source "$script" || echo "    ⚠️  Warning: $script failed"
}

# Install common configs (all distros)
source "$OMARCHY_INSTALL/common/configs.sh"
install_common_configs "$OMARCHY_PATH"
install_bash_config "$OMARCHY_PATH"

# Set up default theme (required for nvim and other themed components)
echo "⚙️  Setting up default theme..."
DEFAULT_THEME="${OMARCHY_DEFAULT_THEME:-tokyo-night}"
if [[ -d "$OMARCHY_PATH/themes/$DEFAULT_THEME" ]]; then
  omarchy-theme-set "$DEFAULT_THEME" 2>/dev/null || echo "  ⚠️  Theme setup had some warnings (non-critical)"
else
  echo "  ⚠️  Default theme '$DEFAULT_THEME' not found, skipping theme setup"
fi

# Run post-package setup scripts (after theme is set up)
echo "⚙️  Running package-specific setups..."
run_logged "$OMARCHY_INSTALL/packaging/nvim.sh" 2>/dev/null || true

# Run remaining config scripts (headless-safe ones)
echo "⚙️  Running system configuration..."
source "$OMARCHY_INSTALL/helpers/all.sh" 2>/dev/null || true

# Skip GUI-specific configs
# Don't run: install/login/* (SDDM, Plymouth)
# Don't run: certain hardware fixes that are GUI-specific

# Run headless-safe config scripts

# System configs that work on headless
run_logged "$OMARCHY_INSTALL/config/git.sh" 2>/dev/null || true
run_logged "$OMARCHY_INSTALL/config/gpg.sh" 2>/dev/null || true
run_logged "$OMARCHY_INSTALL/config/docker.sh" 2>/dev/null || true
run_logged "$OMARCHY_INSTALL/config/ssh-flakiness.sh" 2>/dev/null || true
run_logged "$OMARCHY_INSTALL/config/increase-file-watchers.sh" 2>/dev/null || true
run_logged "$OMARCHY_INSTALL/config/timezones.sh" 2>/dev/null || true
# ... add other headless-safe configs

echo ""
echo "✅ Omarchy Headless installation complete!"
echo ""
echo "Next steps:"
echo "  1. Start a new shell or run: source ~/.bashrc"
echo "  2. Verify with: omarchy-version"
echo "  3. For updates, run: omarchy-update"
echo ""
echo "Note: This is a headless installation. GUI components have been excluded."
