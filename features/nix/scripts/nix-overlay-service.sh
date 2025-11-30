#!/bin/bash

# Create systemd service for overlayfs

cat << 'EOF' > /etc/systemd/system/nix-overlay.service
[Unit]
Description=Mount OverlayFS for /nix
DefaultDependencies=no
After=local-fs.target
Before=nix-daemon.service

[Service]
Type=oneshot
ExecStart=/usr/bin/mount-nix-overlay.sh
RemainAfterExit=yes
ConditionPathExists=/usr/bin/mount-nix-overlay.sh

[Install]
WantedBy=multi-user.target
EOF

# Enable service
systemctl enable nix-overlay.service