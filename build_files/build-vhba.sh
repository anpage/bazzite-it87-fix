#!/bin/bash
set -ouex pipefail

KVER="$(ls /usr/lib/modules)"

dnf5 -y copr enable rok/cdemu

dnf5 install -y akmods
dnf5 install -y --setopt=tsflags=noscripts akmod-vhba

id akmods &>/dev/null || systemd-sysusers /usr/lib/sysusers.d/akmods.conf
OUTDIR="$(mktemp -d -p /tmp)"
chown akmods:akmods "${OUTDIR}"
(cd "${OUTDIR}" && setpriv --reuid=akmods --regid=akmods --init-groups --reset-env \
    /usr/sbin/akmodsbuild --kernels "${KVER}" --outputdir "${OUTDIR}" \
    /usr/src/akmods/vhba-kmod.latest)

mapfile -t RPMS < <(find "${OUTDIR}" -type f -name 'kmod-vhba-*.rpm' \
    ! -name '*.src.rpm' ! -name '*debug*')
[[ ${#RPMS[@]} -eq 1 ]]
rpm -qlp "${RPMS[0]}" | grep -q "/usr/lib/modules/${KVER}/extra/vhba/vhba.ko"
install -Dm0644 "${RPMS[0]}" "/out/rpms/$(basename "${RPMS[0]}")"
