#!/usr/bin/env bash
#./pre-install.sh

#
# bail out on the slightest error (will abort packer build)
#
set -e

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
# this helps with installations
#
export DEBIAN_FRONTEND=noninteractive

#
# install basic packages available in every image
#
sudo apt-get -y -u install \
  screen \
  golang \
  htop \
  atop \
  tcpdump \
  vim \
  ntpdate \
  traceroute \
  $BASIC_PACKAGES

#
# inject the screenrc with the AMI image identifier string
#
sudo tee /root/.screenrc<<EOF
hardstatus alwayslastline

hardstatus string '%{= kG} $AMI_NAME [%= %{= kw}%?%-Lw%?%{r}[%{W}%n*%f %t%?{%u}%?%{r}]%{w}%?%+Lw%?%?%= %{g}] %{W}%{g}%{.w} $IMAGE_TYPE %{.c} [%H]'
EOF

sudo sed -i 's,master image,MASTER image,g;' /root/.screenrc
sudo sed -i 's,worker image,WORKER image,g;' /root/.screenrc

#
# copy the screenrc to the ubuntu user
#
sudo cp /root/.screenrc /home/ubuntu/.screenrc
sudo chown ubuntu: /home/ubuntu/.screenrc

#
# install google packages key for kubernetes repository
#
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
  sudo apt-key add -

#
# set up kubernetes repository
#
sudo tee /etc/apt/sources.list.d/kubernetes.list <<EOF
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

#
# lets see if there are any upgraded packages in there (note that bootstrap already ran dist-upgrade)
#
sudo apt-get update
sudo apt-get dist-upgrade -y -u

#
# install kubernetes and kubeadm dependencies
#
sudo apt-get install -y -u apt-transport-https \
  kubelet \
  kubectl \
  kubernetes-cni \
  kubeadm \
  docker-engine

#
# set up .vimrc
#
sudo tee /root/.vimrc<<EOF
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
sudo cp /root/.vimrc /home/ubuntu/.vimrc
sudo chown ubuntu: /home/ubuntu/.vimrc

#
# pin the timezone of the image
#
sudo ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

#
# install and activate ntp
#
sudo apt-get install -y -u ntp
for CMD in "enable" "start"; do
  sudo systemctl $CMD ntp
done

exit 0

