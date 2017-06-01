#!/usr/bin/env bash
#./pre-install.sh

set -e
set -x

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
# this helps with installations
#
export DEBIAN_FRONTEND=noninteractive

#
# lets see if there are any upgraded packages in there (note that bootstrap already ran dist-upgrade)
#
sudo apt-get update
sudo apt-get dist-upgrade -y -u
sudo apt-get autoremove -y

#
# install packages
#
sudo apt-get install -y -u \
  wget \
  curl \
  unzip \
  screen \
  glances \
  htop \
  atop \
  tcpdump \
  vim \
  ntpdate \
  traceroute \
  bridge-utils \
  netcat \
  ngrep \
  ipcalc \
  apt-transport-https \
  kubelet \
  kubectl \
  kubernetes-cni \
  kubeadm \
  ntp \
  docker-engine \
  $BASIC_PACKAGES

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
# pin the timezone of the image
#
sudo ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

#
# activate ntp
#
for CMD in "enable" "start"; do
  sudo systemctl $CMD ntp
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
# disable UFW
#
systemctl stop ufw
systemctl disable ufw
apt remove -y ufw

exit 0
