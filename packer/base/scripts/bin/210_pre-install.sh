#!/usr/bin/env bash

set -e
set -x

if [[ ! "0" == "$(id -u)" ]]; then
  exec sudo -E $0 $@
fi

if [[ "" == "$BASIC_PACKAGES" ]]; then
  echo "ERROR: environment variable BASIC_PACKAGES is not set"
  exit 1
fi

if [[ "" == "$AMI_NAME" ]]; then
  echo "ERROR: environment variable AMI_NAME is not set"
  exit 1
fi

if [[ "" == "$IMAGE_TYPE" ]]; then
  echo "ERROR: environment variable IMAGE_TYPE is not set"
  exit 1
fi

#
# htop on /dev/tty0
#
mkdir -pv /root/INSTALL && cd /root/INSTALL
test -d quiescence || git clone https://github.com/agabert/quiescence.git
cd quiescence && git pull origin master && make
cd

#
# install google packages key for kubernetes repository
#
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

#
# set up kubernetes repository
#
tee /etc/apt/sources.list.d/kubernetes.list <<EOF
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update
apt-get -y -u dist-upgrade
apt-get autoremove -y

apt-get -y -u install \
  kubelet \
  kubectl \
  kubeadm \
  kubernetes-cni $BASIC_PACKAGES

#
# set up .vimrc
#
tee /root/.vimrc<<EOF
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
# copy the vimrc to the ubuntu user
#
cp /root/.vimrc /home/ubuntu/.vimrc
chown ubuntu: /home/ubuntu/.vimrc

#
# pin the timezone of the image
#
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

#
# activate ntp
#
for CMD in "enable" "start"; do
  systemctl $CMD ntp
done

#
# inject github user keys
#
if [[ ! "" == "$GITHUB_KEYS" ]]; then
  for GITHUB_KEY in $GITHUB_KEYS; do
    echo "## github keys for user [$GITHUB_KEY] injected at $(LANG=C date +%s)" | tee -a /home/ubuntu/.ssh/authorized_keys
    wget -SO- https://github.com/${GITHUB_KEY}.keys | tee -a /home/ubuntu/.ssh/authorized_keys
  done
fi

#
# CNI
#
sudo mkdir -pv /etc/cni/net.d
sudo tee /etc/cni/net.d/10-weave.conf<<EOF
{
    "name": "weave",
    "type": "weave-net",
    "hairpinMode": true
}
EOF

#
# CLOUD
#
systemctl stop kubelet || echo
mkdir -pv /etc/systemd/system/kubelet.service.d
tee /etc/systemd/system/kubelet.service.d/77-kubeadm.conf<<EOF
[Service]
Environment="KUBELET_EXTRA_ARGS=--cloud-provider=aws"
EOF

systemctl daemon-reload

#
# root logins
#
sed 's|disable_root: true|disable_root: false|g;' /etc/cloud/cloud.cfg
systemctl restart cloud-init

mkdir -pv /root/.ssh
cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/authorized_keys
chown -Rv root:root /root

chmod -v 0755 /root /root/.ssh
chmod -v 0644 /root/.ssh/authorized_keys

exit 0
