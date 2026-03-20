#!/usr/bin/env python3
"""
Filter upstream package lists for headless installation.
Removes GUI packages while preserving CLI essentials.
"""

import os
import re
from pathlib import Path

# GUI packages to exclude
GUI_PACKAGES = {
    # Display/Window Management
    "hyprland",
    "hyprland-guiutils",
    "hyprland-preview-share-picker",
    "hypridle",
    "hyprlock",
    "hyprsunset",
    "hyprpicker",
    "waybar",
    "mako",
    "swayosd",
    "swaybg",
    "sway-contrib",
    "uwsm",
    "sddm",
    "plymouth",
    # Terminals
    "alacritty",
    "kitty",
    "ghostty",
    # Screenshot/Clipboard (Wayland-specific)
    "grim",
    "slurp",
    "wl-clipboard",
    "hyprland-qtutils",
    "hyprland-qt-support",
    # Desktop Apps
    "chromium",
    "1password-beta",
    "obsidian",
    "spotify",
    "signal-desktop",
    "kdenlive",
    "obs-studio",
    "mpv",
    "imv",
    "pinta",
    "xournalpp",
    "nautilus",
    "nautilus-python",
    "gnome-disk-utility",
    "evince",
    "typora",
    "localsend",
    "libreoffice-fresh",
    "gnome-calculator",
    # GUI Input/Control
    "bluetui",
    "wiremix",
    "tobi-try",
    "fcitx5",
    "fcitx5-gtk",
    "fcitx5-qt",
    "polkit-gnome",
    "system-config-printer",
    "gnome-themes-extra",
    "gnome-keyring",
    "yaru-icon-theme",
    # Printing (headless servers rarely need)
    "cups",
    "cups-browsed",
    "cups-filters",
    "cups-pdf",
    # File sharing (GVFS - mostly GUI file manager support)
    "gvfs-mtp",
    "gvfs-nfs",
    "gvfs-smb",
    # GPU/Graphics
    "gpu-screen-recorder",
    "kvantum-qt5",
    "egl-wayland",
    "gtk4-layer-shell",
    # Wayland/Graphics drivers (GUI-only)
    "vulkan-intel",
    "vulkan-radeon",
    "vulkan-asahi",
    "libva-intel-driver",
    "libva-nvidia-driver",
    # NVIDIA (unless using for compute - install via omarchy-setup-nvidia)
    "nvidia-dkms",
    "nvidia-580xx-dkms",
    "nvidia-open-dkms",
    "nvidia-utils",
    "nvidia-580xx-utils",
    "lib32-nvidia-utils",
    "lib32-nvidia-580xx-utils",
    # Themes/Icons (GUI-only)
    "imagemagick",
    "ffmpegthumbnailer",
    "aether",
    "sushi",
    "qt5-wayland",
    "qt6-wayland",
    # Laptop/Desktop Hardware (not needed on most servers)
    "brightnessctl",
    "asdcontrol",
    "pamixer",
    # Hardware-specific (install via omarchy-setup-* commands)
    "asusctl",
    "broadcom-wl",
    "macbook12-spi-driver-dkms",
    "apple-bcm-firmware",
    "apple-t2-audio-config",
    "linux-t2",
    "linux-t2-headers",
    "t2fanrd",
    "tiny-dfr",
    "linux-firmware-marvell",
    # Additional GUI apps found in upstream
    "omarchy-walker",  # GUI app launcher
    "satty",  # Screenshot annotation
    "impala",  # Music player TUI (GUI-like)
    "playerctl",  # Media player control (GUI-focused)
}

# Additional patterns to exclude (regex)
GUI_PATTERNS = [
    r"^gtk\d?-.*",
    r"^qt\d?-wayland",
    r"^xdg-desktop-portal.*",
    r"^nvidia-.*",
]


def is_gui_package(pkg: str) -> bool:
    """Check if package is GUI-related."""
    pkg_lower = pkg.lower()

    # Direct match
    if pkg_lower in GUI_PACKAGES:
        return True

    # Pattern match
    for pattern in GUI_PATTERNS:
        if re.match(pattern, pkg_lower):
            return True

    return False


def filter_package_list(input_file: Path, output_file: Path) -> None:
    """Filter a package list file."""
    print(f"Filtering {input_file}...")

    if not input_file.exists():
        print(f"  Warning: {input_file} not found")
        return

    kept = []
    removed = []

    with open(input_file, "r") as f:
        for line in f:
            line = line.strip()

            # Skip comments and empty lines
            if not line or line.startswith("#"):
                kept.append(line)
                continue

            # Check if GUI package
            if is_gui_package(line):
                removed.append(line)
            else:
                kept.append(line)

    # Write filtered list
    output_file.parent.mkdir(parents=True, exist_ok=True)
    with open(output_file, "w") as f:
        f.write("\n".join(kept))
        f.write("\n")

    print(f"  Kept: {len([k for k in kept if k and not k.startswith('#')])}")
    print(f"  Removed: {len(removed)}")
    if removed:
        print(f"  Removed packages: {', '.join(removed[:10])}")
        if len(removed) > 10:
            print(f"    ... and {len(removed) - 10} more")


def main():
    repo_root = Path(os.environ.get("OMARCHY_PATH", Path(__file__).parent.parent))
    install_dir = repo_root / "install"

    # Filter upstream package lists
    filter_package_list(
        install_dir / "omarchy-base.packages",
        install_dir / "distros" / "arch" / "packages.list",
    )

    # Copy other packages as-is (usually not GUI-heavy)
    other_packages = install_dir / "omarchy-other.packages"
    if other_packages.exists():
        filter_package_list(
            other_packages, install_dir / "distros" / "arch" / "packages-other.list"
        )

    print("\n✅ Package filtering complete!")


if __name__ == "__main__":
    main()
