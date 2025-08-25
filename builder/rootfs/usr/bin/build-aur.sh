#!/usr/bin/env bash

aur_cache_dir="/var/cache/trellis/aur"
local_pkgbuild_dir="/pkgbuilds"

# Ensure we have proper permisions
chown builder:builder -R $aur_cache_dir

# Ensure package databases are up to date
pacman -Sy

# Parse input
aur_pkgs=()
local_pkgs=()
args="-fcCs --noconfirm"

while test $# -gt 0; do
    case "$1" in
    -l | --local)
        local_pkgs+=("$2")
        shift 2
        ;;
    -*)
        args="$args $1"
        shift
        ;;
    *)
        aur_pkgs+=("$1")
        shift
        ;;
    esac
done

# Copy local packages to cache
for pkg in "${local_pkgs[@]}"; do
    cp -r $local_pkgbuild_dir/$pkg $aur_cache_dir/
    chown builder:builder $aur_cache_dir/$pkg
done

# Fetch requested AUR packages
for pkg in "${aur_pkgs[@]}"; do
    if [[ ! -d "$aur_cache_dir/$pkg" ]]; then
        # Get sources
        su builder -c "git clone https://aur.archlinux.org/$pkg.git $aur_cache_dir/$pkg"
    else
        # Update existing sources
        cd $aur_cache_dir/$pkg
        su builder -c "git reset --hard && git pull"
    fi
done

# Build pkgs
pkgs=("${aur_pkgs[@]}" "${local_pkgs[@]}")
for pkg in "${pkgs[@]}"; do
    # Check if package exists in cache before building
    cd $aur_cache_dir/$pkg
    need_build=false
    for filename in $(su builder -c 'makepkg --packagelist'); do
        if [[ -f "$filename" ]]; then
            echo "$filename already built"
        else
            need_build=true
            echo "$filename not built or needs update"
            rm -f *.pkg.tar.zst
            break
        fi
    done
    # Build package
    ($need_build) && su builder -c "makepkg $args"
    # Copy to staging directory
    cp $aur_cache_dir/$pkg/*.pkg.* /aur
done
