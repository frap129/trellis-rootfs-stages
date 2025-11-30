ARG BASE_IMAGE=${BASE_IMAGE}
FROM ${BASE_IMAGE} AS nix

# Install nix
RUN pacman -S --noconfirm nix && systemctl enable nix-daemon.socket

# Create directories for overlayfs setup
RUN mkdir -p /usr/share/nix-store \
    && mkdir -p /var/lib/nix-store \
    && mkdir -p /var/cache/nix-store \
    && mkdir -p /nix

# Load overlay module at boot
RUN echo overlay > /etc/modules-load.d/overlay.conf

# Copy scripts
COPY scripts/mount-nix-overlay.sh /usr/bin/mount-nix-overlay.sh
COPY scripts/nix-overlay-service.sh /tmp/nix-overlay-service.sh

# Make scripts executable
RUN chmod +x /usr/bin/mount-nix-overlay.sh \
    && chmod +x /tmp/nix-overlay-service.sh

# Create and enable systemd service
RUN /tmp/nix-overlay-service.sh && rm /tmp/nix-overlay-service.sh

# Move existing nix store if present
RUN if [ -d /nix/store ]; then \
    mv /nix/* /usr/share/nix-store/; \
    fi
