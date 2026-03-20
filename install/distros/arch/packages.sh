#!/bin/bash
# Arch Linux package operations

# Ensure yay is installed
ensure_aur_helper() {
  if command -v yay &>/dev/null; then
    echo "✅ yay already installed"
    return 0
  fi
  
  echo "📦 Installing yay (AUR helper)..."
  sudo pacman -S --needed --noconfirm git base-devel
  
  # Build yay in temp directory
  local temp_dir=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$temp_dir/yay"
  cd "$temp_dir/yay"
  makepkg -si --noconfirm
  cd -
  rm -rf "$temp_dir"
  
  echo "✅ yay installed"
}

# Install packages from list
install_packages_from_list() {
  local list_file="$1"
  
  if [[ ! -f "$list_file" ]]; then
    echo "❌ Package list not found: $list_file"
    return 1
  fi
  
  echo "📦 Installing packages from $list_file..."
  
  # Filter out comments and empty lines, install
  grep -v '^#' "$list_file" | grep -v '^$' | while read pkg; do
    if ! pacman -Q "$pkg" &>/dev/null; then
      echo "  Installing: $pkg"
      sudo pacman -S --needed --noconfirm "$pkg" || {
        echo "  ⚠️  Failed to install: $pkg"
      }
    else
      echo "  ✅ Already installed: $pkg"
    fi
  done
}

# Install AUR packages
install_aur_packages_from_list() {
  local list_file="$1"
  
  if [[ ! -f "$list_file" ]]; then
    echo "ℹ️  No AUR package list found: $list_file"
    return 0
  fi
  
  echo "📦 Installing AUR packages from $list_file..."
  
  grep -v '^#' "$list_file" | grep -v '^$' | while read pkg; do
    if ! yay -Q "$pkg" &>/dev/null; then
      echo "  Installing from AUR: $pkg"
      yay -S --needed --noconfirm "$pkg" || {
        echo "  ⚠️  Failed to install from AUR: $pkg"
      }
    else
      echo "  ✅ Already installed: $pkg"
    fi
  done
}

# Main install function
install_arch_packages() {
  local install_dir="$1"
  
  echo "🎯 Installing packages for Arch Linux..."
  
  # Update package database
  echo "📡 Updating package database..."
  sudo pacman -Sy
  
  # Ensure AUR helper
  ensure_aur_helper
  
  # Install official packages
  install_packages_from_list "$install_dir/distros/arch/packages.list"
  
  # Install AUR packages
  install_aur_packages_from_list "$install_dir/distros/arch/packages-aur.list"
  
  echo "✅ Arch package installation complete"
}
