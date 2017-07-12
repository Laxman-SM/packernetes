#!/usr/bin/env bash
#./install.sh

set -e
set -x

USER_DATA_URL="http://169.254.169.254/latest/user-data"

# if environment variable TOKEN has been set, do not overwrite it
if [[ "" == "$TOKEN" ]]; then
  TOKEN="$1"
fi

# $1 was empty
if [[ "" == "$TOKEN" ]]; then
  USER_DATA="$(wget --timeout=5 -qO- $USER_DATA_URL)"
  TOKEN="$(echo "$USER_DATA" | awk -F'|' {'print $1;'})"
fi

# user-data was empty or not reachable
if [[ "" == "$TOKEN" ]]; then
  export TOKEN="$(kubeadm token generate)"

  for i in $(seq 1 20); do
    sleep 1
    echo
    echo "WARNING using autogenerated token: [[$TOKEN]]"
    echo
  done
fi

sudo -i timeout 10 docker ps || sudo -i systemctl restart docker.service

sudo mkdir -pv /etc/packernetes/master

sudo tee /etc/packernetes/master/kubeadm.conf<<EOF
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
cloudProvider: aws

token: $TOKEN
EOF

sudo kubeadm init \
  --token "$TOKEN" \
  --apiserver-cert-extra-sans "localhost.localdomain,localhost,127.0.0.1" \
  --config /etc/packernetes/master/kubeadm.conf
