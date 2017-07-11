#!/usr/bin/env bash
#./docker-ce.sh

set -e
set -x

sudo apt-get install -y -u docker.io

sudo systemctl restart docker

exit 0
