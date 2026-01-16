#!/usr/bin/bash
set -e

# Bind mount /var/nix to /nix
# This makes /nix appear as a real directory (not symlink)
mount --bind /var/nix /nix
