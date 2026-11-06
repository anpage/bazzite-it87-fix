#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

# it87: replace the in-tree module with the out-of-tree build (see build-it87.sh)
KVER="$(ls /usr/lib/modules)"
[[ "$(cat /kmods/kver)" == "${KVER}" ]]
rm -f "/usr/lib/modules/${KVER}/kernel/drivers/hwmon/it87.ko"*
install -Dm0644 /kmods/it87.ko "/usr/lib/modules/${KVER}/extra/it87.ko"
depmod -a "${KVER}"

# CDEmu
modinfo -k "${KVER}" -F filename vhba
rpm -q kmod-vhba vhba
dnf5 -y copr enable rodoma92/kde-cdemu-manager
dnf5 install -y --enable-repo='copr:copr.fedorainfracloud.org:rok:cdemu' \
    --exclude=akmod-vhba,dkms-vhba \
    cdemu-daemon cdemu-client kde-cdemu-manager
dnf5 -y copr disable rodoma92/kde-cdemu-manager

for pkg in akmod-vhba dkms-vhba; do
    if rpm -q "${pkg}" &>/dev/null; then
        echo "${pkg} was pulled in. Bazzite's own vhba kmod should satisfy cdemu." >&2
        exit 1
    fi
done
