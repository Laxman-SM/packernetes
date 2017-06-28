#!/usr/bin/env bash
#./docker-ce.sh

set -e
set -x

sudo apt-get remove -y docker docker-engine || echo

sudo apt-get install -y -u \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update

sudo apt-get install -y -u \
    docker-ce

sudo apt-get update
sudo apt-get dist-upgrade -y -u
sudo apt-get autoremove -y

sudo docker run hello-world

exit 0
