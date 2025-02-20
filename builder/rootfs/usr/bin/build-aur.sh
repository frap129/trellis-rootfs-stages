#!/usr/bin/env bash

aur_cache_dir="/aur-cache"

# Ensure we have proper permisions
chown builder:builder $aur_cache_dir -R

# Ensure package databases are up to date
pacman -Sy

# Parse input
pkgs=()
args="-fcCs --noconfirm"
while test $# -gt 0; do
    case "$1" in
    -*)
        args="$args $1"
        shift
        ;;
    *)
        pkgs+=("$1")
        shift
        ;;
    esac
done

# Build requested packages
for pkg in "${pkgs[@]}"; do
    if [[ ! -d "$aur_cache_dir/$pkg" ]]; then
        # Get sources
        su builder -c "git clone https://aur.archlinux.org/$pkg.git $aur_cache_dir/$pkg"
        cd $aur_cache_dir/$pkg
    else
        # Update existing sources
        cd $aur_cache_dir/$pkg
        su builder -c "git reset --hard && git pull"
    fi

    # Check if package exists in cache before building
    need_build=false
    for filename in "$(su builder -c 'makepkg --packagelist')"; do
        filename="$(echo $filename | rev | cut -d/ -f1 | rev)"
        if [[ -f "$filename" ]]; then
            echo "$filename already built"
        else
            need_build=true
            rm *.pkg.tar.zst
            break
        fi
    done

    # Build package
    ($need_build) && su builder -c "makepkg $args"

    # Copy to staging directory
    cp $aur_cache_dir/$pkg/${pkg}-*.pkg.* /aur
done
