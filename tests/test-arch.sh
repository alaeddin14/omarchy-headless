#!/bin/bash
# Test Omarchy Headless installation on Arch Linux

set -e

echo "🧪 Testing Omarchy Headless Installation"
echo "========================================"

# Test 1: Package installation
echo ""
echo "Test 1: Package Installation"
command -v git &>/dev/null && echo "✅ git installed" || echo "❌ git missing"
command -v fzf &>/dev/null && echo "✅ fzf installed" || echo "❌ fzf missing"
command -v eza &>/dev/null && echo "✅ eza installed" || echo "❌ eza missing"
command -v starship &>/dev/null && echo "✅ starship installed" || echo "❌ starship missing"
command -v btop &>/dev/null && echo "✅ btop installed" || echo "❌ btop missing"

# Test 2: No GUI packages
echo ""
echo "Test 2: GUI Packages Should NOT Be Installed"
! command -v hyprland &>/dev/null && echo "✅ hyprland not installed" || echo "❌ hyprland should not be installed"
! command -v waybar &>/dev/null && echo "✅ waybar not installed" || echo "❌ waybar should not be installed"
! command -v alacritty &>/dev/null && echo "✅ alacritty not installed" || echo "❌ alacritty should not be installed"

# Test 3: Config files
echo ""
echo "Test 3: Configuration Files"
[[ -f ~/.config/git/config ]] && echo "✅ git config exists" || echo "❌ git config missing"
[[ -f ~/.config/starship.toml ]] && echo "✅ starship.toml exists" || echo "❌ starship.toml missing"
[[ -f ~/.bashrc ]] && echo "✅ bashrc exists" || echo "❌ bashrc missing"
[[ -d ~/.config/nvim ]] && echo "✅ nvim config exists" || echo "❌ nvim config missing"

# Test 4: Bash sourcing
echo ""
echo "Test 4: Bash Configuration"
grep -q "Omarchy" ~/.bashrc 2>/dev/null && echo "✅ bashrc references Omarchy" || echo "❌ bashrc missing Omarchy reference"

# Test 5: No GUI directories
echo ""
echo "Test 5: GUI Configs Should NOT Exist"
[[ ! -d ~/.config/hypr ]] && echo "✅ ~/.config/hypr does not exist" || echo "❌ ~/.config/hypr should not exist"
[[ ! -d ~/.config/waybar ]] && echo "✅ ~/.config/waybar does not exist" || echo "❌ ~/.config/waybar should not exist"

# Test 6: Commands (use interactive shell for bashrc-loaded commands)
echo ""
echo "Test 6: Omarchy Commands"
bash -ic "command -v omarchy-version &>/dev/null" && echo "✅ omarchy-version available" || echo "❌ omarchy-version missing"
bash -ic "command -v omarchy-update &>/dev/null" && echo "✅ omarchy-update available" || echo "❌ omarchy-update missing"
bash -ic "command -v omarchy-pkg-add &>/dev/null" && echo "✅ omarchy-pkg-add available" || echo "❌ omarchy-pkg-add missing"

echo ""
echo "========================================"
echo "🎉 Test Complete!"
