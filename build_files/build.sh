#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

KVER="$(ls /usr/lib/modules)"
[[ "$(cat /it87/kver)" == "${KVER}" ]]
rm -f "/usr/lib/modules/${KVER}/kernel/drivers/hwmon/it87.ko"*
install -Dm0644 /it87/it87.ko "/usr/lib/modules/${KVER}/extra/it87.ko"
depmod -a "${KVER}"

# CoolerControl
cp /etc/yum.repos.d/terra.repo /tmp/terra.repo.bak
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/terra.repo
dnf5 install -y coolercontrol liquidctl
cp /tmp/terra.repo.bak /etc/yum.repos.d/terra.repo
systemctl enable coolercontrold.service

# CDEmu
dnf5 -y copr enable rok/cdemu
dnf5 -y copr enable rodoma92/kde-cdemu-manager
dnf5 install -y cdemu-daemon cdemu-client kde-cdemu-manager-kf6
dnf5 -y copr disable rodoma92/kde-cdemu-manager
dnf5 -y copr disable rok/cdemu

for pkg in akmod-vhba dkms-vhba; do
    if rpm -q "${pkg}" &>/dev/null; then
        echo "${pkg} was pulled in. Bazzite's own vhba kmod should satisfy cdemu." >&2
        exit 1
    fi
done
