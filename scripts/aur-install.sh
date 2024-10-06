#!/usr/bin/env bash

# Install temp dependencies
pacman -S --noconfirm \
    base-devel \
    sudo

# Setup build user
useradd -m --shell=/bin/bash build && usermod -L build
echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/build-temp
echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/build-temp
mkdir /home/build && chown build:build -R /home/build

# Install AUR packages
su build -c "yay -S --noconfirm --cleanafter --removemake $@"

# Remove build user and package cache
rm -drf /home/build /etc/sudoers.d/build-temp /tmp/*
userdel -r build
paccache -rk0

# Remove temp dependencies
pacman -Rcns --noconfirm \
    base-devel \
    sudo




