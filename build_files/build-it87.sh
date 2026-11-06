#!/bin/bash

set -ouex pipefail

# The in-tree driver (Linux >= 7.1) detects the IT8689E on the Gigabyte X570S
# AORUS ELITE but manual PWM writes have no effect.
# The fork's MMIO/H2RAM support makes fan control work.
# Details and test results: https://github.com/ublue-os/akmods/issues/382
IT87_COMMIT="bd7a566c8a60fe0308d67e26761e16260368191a"

KVER="$(ls /usr/lib/modules)"
KDIR="/usr/src/kernels/${KVER}"
test -d "${KDIR}"

dnf5 install -y gcc make git elfutils-libelf-devel

want="$(sed -n 's/^CONFIG_CC_VERSION_TEXT=//p' "${KDIR}/include/config/auto.conf" | tr -d '"')"
have="$(gcc --version | head -n1)"
[[ "${have}" == "${want}" ]]

git clone https://github.com/frankcrawford/it87 /tmp/it87
git -C /tmp/it87 checkout "${IT87_COMMIT}"
make -C "${KDIR}" M=/tmp/it87 modules

install -Dm0644 /tmp/it87/it87.ko /out/it87.ko
echo "${KVER}" > /out/kver
