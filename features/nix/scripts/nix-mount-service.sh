#!/bin/bash
set -e

mkdir -p /usr/lib/systemd/system
cat <<'EOF' >/usr/lib/systemd/system/nix-mount.service
[Unit]
Description=Bind mount /var/nix to /nix
DefaultDependencies=no
After=local-fs.target
Before=nix-daemon.socket nix-daemon.service
ConditionPathIsMountPoint=!/nix

[Service]
Type=oneshot
ExecStart=/usr/bin/mount-nix.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl enable nix-mount.service
