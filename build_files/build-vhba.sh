#!/bin/bash
set -ouex pipefail

KVER="$(ls /usr/lib/modules)"

dnf5 -y copr enable rok/cdemu

dnf5 install -y akmods
dnf5 install -y --setopt=tsflags=noscripts akmod-vhba

rm -rf /var/cache/akmods/vhba
akmods --force --kernels "${KVER}" --kmod vhba
modinfo "/usr/lib/modules/${KVER}/extra/vhba/vhba.ko.xz" > /dev/null \
    || (find /var/cache/akmods/vhba/ -name '*.log' -print -exec cat {} \; && exit 1)

mapfile -t RPMS < <(find /var/cache/akmods/vhba -type f -name 'kmod-vhba-*.rpm' \
    ! -name '*.src.rpm' ! -name '*debug*')
[[ ${#RPMS[@]} -eq 1 ]]
install -Dm0644 "${RPMS[0]}" "/out/rpms/$(basename "${RPMS[0]}")"
