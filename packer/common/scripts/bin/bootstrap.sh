#!/usr/bin/env bash
#./bootstrap.sh

set -e
set -x

export DEBIAN_FRONTEND=noninteractive

sudo debconf-set-selections <<EOF
grub grub/update_grub_changeprompt_threeway select install_new
grub-legacy-ec2 grub/update_grub_changeprompt_threeway select install_new
EOF

sudo dpkg --configure -a

#
# update the software in the image to the latest packages available
#
sudo apt-get update
sudo apt-get dist-upgrade -y -u
sudo apt-get autoremove -y

#
# install everything that is necessary to run the scripts uploaded via packer
#
sudo apt-get install -y -u make golang python wget curl git rsync

sync
