# Omarchy Headless

**⚠️ Unofficial Community Project**

This is an **unofficial** headless server variant of Omarchy, created by the community. It is **not affiliated with** or endorsed by Basecamp or the original Omarchy team.

| | Link |
|---|---|
| **Official Omarchy** | [basecamp/omarchy](https://github.com/basecamp/omarchy) |
| **This Fork** | Community-maintained headless variant |
| **Relationship** | Fork with GUI components removed |

---

Omarchy's excellent CLI/terminal experience for headless servers.

## What is this?

[Omarchy](https://omarchy.org/) is a beautiful, opinionated Arch Linux distribution. However, it's designed for desktop use with a GUI. **Omarchy Headless** extracts the terminal customization, bash functions, and CLI tool configurations, making them available on headless servers without the GUI components.

## Features

- 🖥️ **Full Terminal Experience** - All bash aliases, functions, and shell enhancements
- 📦 **Smart Package Management** - `omarchy-pkg-*` commands with AUR support
- ⚙️ **Curated Configs** - Git, btop, lazygit, starship, tmux, and more
- 🔄 **Stay Updated** - `omarchy-update` pulls latest configurations
- 🚀 **Existing Servers** - Install on top of current systems, no reinstall needed

## Quick Start

### Option 1: One-Line Install (curl)

```bash
curl -sSL https://raw.githubusercontent.com/alaeddin14/omarchy-headless/dev/boot.sh | bash
```

### Option 2: Manual Install

```bash
git clone https://github.com/alaeddin14/omarchy-headless.git ~/.local/share/omarchy
cd ~/.local/share/omarchy
git checkout dev
source install.sh
```

### After Installation

```bash
# Start a new shell or source bashrc
source ~/.bashrc

# Verify installation
omarchy-version

# For updates
omarchy-update
```

## What's Included

### Shell Experience
- **Aliases:** `ls` → `eza`, `cd` → `zoxide`, `c` → `opencode`, `ff` → `fzf+bat`
- **Functions:** 
  - `tdl()` - Tmux dev layout (editor + AI panels)
  - `tdlm()` - Multi-project dev layouts
  - `tsl()` - Tmux swarm layout
  - `iso2sd()` - Write ISO to SD card
  - `format-drive()` - Format drives to exFAT
  - `fip/dip/lip` - SSH port forwarding helpers
- **Prompt:** Starship with git integration
- **History:** Extended history with deduplication

### CLI Tools
- **Git:** Thoughtful defaults (rebase on pull, autoSetupRemote, histogram diff)
- **Btop:** System monitoring with vim keys
- **Lazygit:** TUI git client
- **Tmux:** Custom layouts and keybindings
- **FZF:** Fuzzy finder with previews
- **Eza:** Modern `ls` replacement

### System Features
- SSH connection hardening
- Docker configuration
- File watcher limits increased
- Bash completion

## Requirements

- Arch Linux (for now)
- Internet connection for package installation
- sudo access

## What's NOT Included

GUI components are excluded:
- Hyprland (window manager)
- Waybar, Mako, Walker (GUI tools)
- Alacritty, Kitty, Ghostty (terminal emulators)
- SDDM (display manager - no login screen)
- Chromium, Obsidian, Spotify (desktop apps)
- Theme wallpapers

## Development

### Sync with Upstream

```bash
./sync/upstream-sync.sh
```

This pulls latest changes from upstream Omarchy and applies headless filters.

### Testing

```bash
# Run tests
docker run -it archlinux:latest /tests/test-arch.sh
```

## Roadmap

- ✅ **Phase 1:** Arch Linux support (current)
- 🚧 **Phase 2:** Debian/Ubuntu support
- 📋 **Phase 3:** Additional distributions

## License

Same as upstream Omarchy. See LICENSE file.
