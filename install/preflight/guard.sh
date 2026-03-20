abort() {
  echo -e "\e[31mOmarchy install requires: $1\e[0m"
  echo
  gum confirm "Proceed anyway on your own accord and without assistance?" || exit 1
}

# Must be an Arch distro
if [[ ! -f /etc/arch-release ]]; then
  abort "Vanilla Arch"
fi

# Must not be an Arch derivative distro
for marker in /etc/cachyos-release /etc/eos-release /etc/garuda-release /etc/manjaro-release; do
  if [[ -f $marker ]]; then
    abort "Vanilla Arch"
  fi
done

# Must not be running as root
if (( EUID == 0 )); then
  abort "Running as root (not user)"
fi

# Must be x86 only to fully work
if [[ $(uname -m) != "x86_64" ]]; then
  abort "x86_64 CPU"
fi

# Must have secure boot disabled
if bootctl status 2>/dev/null | grep -q 'Secure Boot: enabled'; then
  abort "Secure Boot disabled"
fi

# Must not have Gnome or KDE already install
if pacman -Qe gnome-shell &>/dev/null || pacman -Qe plasma-desktop &>/dev/null; then
  abort "Fresh + Vanilla Arch"
fi

# Warn if Limine is not installed (snapper boot entries won't work)
if ! command -v limine &>/dev/null; then
  echo -e "\e[33mNote: Limine not detected. Snapshot boot entries will not be available.\e[0m"
fi

# Warn if not using Btrfs (snapper snapshots won't work)
if [[ $(findmnt -n -o FSTYPE /) != "btrfs" ]]; then
  echo -e "\e[33mNote: Btrfs not detected. Snapper snapshots will not be available.\e[0m"
fi

# Cleared all guards
echo "Guards: OK"
