ARG BASE_IMAGE=${BASE_IMAGE}
FROM ${BASE_IMAGE} AS nix

# Install nix
RUN pacman -S --noconfirm nix && systemctl enable nix-daemon.socket

# Move nix contents to /var/nix (persistent, writable)
# Keep /nix as empty directory (bind mount point)
RUN mv /nix /var/nix \
    && mkdir /nix

# Copy mount script
COPY scripts/mount-nix.sh /usr/bin/mount-nix.sh
RUN chmod +x /usr/bin/mount-nix.sh

# Copy and run service creation script
COPY scripts/nix-mount-service.sh /tmp/nix-mount-service.sh
RUN chmod +x /tmp/nix-mount-service.sh \
    && /tmp/nix-mount-service.sh \
    && rm /tmp/nix-mount-service.sh
