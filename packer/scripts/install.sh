#!/bin/bash
#./packernetes/packer/scripts/install.sh

#
# This script will be called by ALL packer runs, regardless which kind of image you are building
# Only put things here that will be installed on all image types.
#

#
# make sure that any errors in this script will immediately fail the packer run
#
set -e

PACKAGES="${*}"

export DEBIAN_FRONTEND=noninteractive

debconf-set-selections <<EOF
grub grub/update_grub_changeprompt_threeway select install_new
grub-legacy-ec2 grub/update_grub_changeprompt_threeway select install_new
EOF

dpkg --configure -a

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat >/etc/apt/sources.list.d/kubernetes.list <<EOF
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update
apt-get dist-upgrade -y -u

# via https://kubernetes.io/docs/getting-started-guides/kubeadm/
# install golang for the kubeadm launcher
apt-get install -y -u \
  apt-transport-https \
  docker.io \
  kubelet \
  kubeadm \
  kubectl \
  kubernetes-cni \
  golang \
  screen \
  htop \
  atop \
  vim

#
# highly opinionated vimrc
#
cat >/root/.vimrc<<EOF
syntax on

set hlsearch

set list
set listchars=tab:»·,trail:¢

set expandtab

set visualbell
set autoread

set noswapfile
set nobackup
set nowb

set autoindent
set smartindent
set smarttab
set shiftwidth=2
set softtabstop=2
set tabstop=2

filetype on
filetype plugin on
filetype indent on
filetype plugin indent on
EOF

#
# inject the basic packages that the user defined in the Makefile
#
apt-get install -y -u $PACKAGES

#
# pin the timezone of the image
#
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

#
# install and activate ntp
#
apt-get install -y -u ntpdate ntp

for CMD in "enable" "start" "status"; do
  systemctl $CMD ntp
done

exit 0

