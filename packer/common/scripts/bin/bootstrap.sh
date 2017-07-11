#!/usr/bin/env bash
#./bootstrap.sh

set -e
set -x

if [[ ! "0" == "$(id -u)" ]]; then
  exec sudo $0 $@
fi

export DEBIAN_FRONTEND=noninteractive

debconf-set-selections <<EOF
grub grub/update_grub_changeprompt_threeway select install_new
grub-legacy-ec2 grub/update_grub_changeprompt_threeway select install_new
EOF

#
# just in case
#
dpkg --configure -a

#
# update metadata
#
apt-get update

#
# update to latest packages
#
apt-get dist-upgrade -y -u

#
# remove old packages
#
apt-get autoremove -y

#
# install everything that is necessary to run the scripts uploaded via packer
#
apt-get install -y -u make golang python wget curl git rsync

sync
