#!/bin/bash
# Detect Linux distribution

detect_distro() {
  if [[ -f /etc/arch-release ]]; then
    echo "arch"
  elif [[ -f /etc/debian_version ]]; then
    echo "debian"
  elif [[ -f /etc/fedora-release ]]; then
    echo "fedora"
  else
    echo "unknown"
  fi
}

# Usage
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  detect_distro
fi
