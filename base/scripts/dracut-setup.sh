#!/usr/bin/env bash
set -xeo pipefail

args=('--force')

for line in $(find /usr/lib/modules -name pkgbase); do
	read -r pkgbase < "${line}"
	kver="${line#'/usr/lib/modules/'}"
	kver="${kver%'/pkgbase'}"

	install -Dm0644 "/${line%'/pkgbase'}/vmlinuz" "/boot/vmlinuz-${pkgbase}"
	dracut "${args[@]}" "/boot/initramfs-${pkgbase}.img" --kver "$kver"
done
