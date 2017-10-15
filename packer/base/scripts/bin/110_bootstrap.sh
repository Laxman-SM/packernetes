#!/usr/bin/env bash

set -e
set -x

if [[ ! "0" == "$(id -u)" ]]; then
  exec sudo -E $0 $@
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
# install basic packages
#
apt-get install -y -u \
  ntp \
  screen tmux \
  htop glances ltrace strace lsof \
  tcpdump traceroute bridge-utils netcat ngrep ipcalc \
  make git golang python \
  rsync unzip wget curl \
  awscli \
  apt-transport-https \
  docker.io

sync
