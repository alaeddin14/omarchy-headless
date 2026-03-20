#!/bin/bash

# Set install mode to online since boot.sh is used for curl installations
export OMARCHY_ONLINE_INSTALL=true
export OMARCHY_HEADLESS=true

echo "
╔══════════════════════════════════════════════════════════════╗
║           Omarchy Headless Installer                         ║
║           CLI Experience for Headless Servers                ║
╚══════════════════════════════════════════════════════════════╝
"

# Use custom branch if instructed, otherwise default to dev
OMARCHY_REF="${OMARCHY_REF:-dev}"

# Detect if we're on Arch
if [[ ! -f /etc/arch-release ]]; then
  echo "❌ This installer currently only supports Arch Linux"
  echo "Detected distro: $(cat /etc/os-release 2>/dev/null | grep '^ID=' | cut -d= -f2 || echo 'unknown')"
  echo ""
  echo "For other distributions, see: https://github.com/alaeddin14/omarchy-headless"
  exit 1
fi

# Set mirror based on branch (from upstream Omarchy)
if [[ $OMARCHY_REF == "dev" ]]; then
  export OMARCHY_MIRROR=edge
  echo 'Server = https://mirror.omarchy.org/$repo/os/$arch' | sudo tee /etc/pacman.d/mirrorlist >/dev/null
elif [[ $OMARCHY_REF == "rc" ]]; then
  export OMARCHY_MIRROR=rc
  echo 'Server = https://rc-mirror.omarchy.org/$repo/os/$arch' | sudo tee /etc/pacman.d/mirrorlist >/dev/null
else
  export OMARCHY_MIRROR=stable
  echo 'Server = https://stable-mirror.omarchy.org/$repo/os/$arch' | sudo tee /etc/pacman.d/mirrorlist >/dev/null
fi

# Add Omarchy repository to pacman.conf
if ! grep -q "\[omarchy\]" /etc/pacman.conf; then
  echo "" | sudo tee -a /etc/pacman.conf >/dev/null
  echo "[omarchy]" | sudo tee -a /etc/pacman.conf >/dev/null
  echo "SigLevel = Optional TrustAll" | sudo tee -a /etc/pacman.conf >/dev/null
  echo "Server = https://pkgs.omarchy.org/stable/\$arch" | sudo tee -a /etc/pacman.conf >/dev/null
fi

echo "📦 Updating package database..."
sudo pacman -Sy --needed --noconfirm git

echo ""
echo "🔄 Cloning Omarchy Headless..."
rm -rf ~/.local/share/omarchy/
git clone "https://github.com/${OMARCHY_REPO:-alaeddin14/omarchy-headless}.git" ~/.local/share/omarchy >/dev/null 2>&1

echo "✅ Using branch: $OMARCHY_REF"
cd ~/.local/share/omarchy
git fetch origin "${OMARCHY_REF}" && git checkout "${OMARCHY_REF}"
cd -

echo ""
echo "🚀 Starting installation..."
source ~/.local/share/omarchy/install.sh
