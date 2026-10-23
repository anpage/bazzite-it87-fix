#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

KVER="$(ls /usr/lib/modules)"
[[ "$(cat /it87/kver)" == "${KVER}" ]]
rm -f "/usr/lib/modules/${KVER}/kernel/drivers/hwmon/it87.ko"*
install -Dm0644 /it87/it87.ko "/usr/lib/modules/${KVER}/extra/it87.ko"
depmod -a "${KVER}"
