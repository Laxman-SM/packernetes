#!/usr/bin/env bash
#./install.sh

set -e
set -x

USER_DATA_URL="http://169.254.169.254/latest/user-data"

if [[ "" == "$TOKEN" ]]; then
  TOKEN="$1"
fi

if [[ "" == "$MASTER" ]]; then
  MASTER="$2"
fi

if [[ "" == "$MASTER_PORT" ]]; then
  MASTER_PORT="$3"
fi

if [[ "" == "$TOKEN" ]]; then
  USER_DATA="$(wget -qO- $USER_DATA_URL)"
  TOKEN="$(echo "$USER_DATA" | awk -F'|' {'print $1;'})"
fi

if [[ "" == "$MASTER" ]]; then
  USER_DATA="$(wget -qO- $USER_DATA_URL)"
  MASTER="$(echo "$USER_DATA" | awk -F'|' {'print $2;'})"
fi

if [[ "" == "$MASTER_PORT" ]]; then
  USER_DATA="$(wget -qO- $USER_DATA_URL)"
  MASTER_PORT="$(echo "$USER_DATA" | awk -F'|' {'print $3;'})"
fi

if [[ "" == "$TOKEN" ]]; then
  echo "ERROR"
  echo "ERROR you did not provide a token"
  echo "ERROR"
  echo "ERROR we checked the environment variable TOKEN and also $USER_DATA_URL"
  echo "ERROR"

  exit 1
fi

if [[ "" == "$MASTER" ]]; then
  echo "ERORR"
  echo "ERROR: master could not be retrieved from environment variable MASTER or $USER_DATA_URL"
  echo "ERROR"

  exit 1
fi

if [[ "" == "$MASTER_PORT" ]]; then
  MASTER_PORT="6443"
fi

sudo -i timeout 10 docker ps || sudo -i systemctl restart docker

sudo mkdir -pv /etc/packernetes/worker

sudo tee /etc/packernetes/worker/kubeadm.conf<<EOF
apiVersion: kubeadm.k8s.io/v1alpha1
kind: NodeConfiguration
cloudProvider: aws

discoveryToken: $TOKEN
discoveryTokenAPIServers:
- $MASTER:$MASTER_PORT

tlsBootstrapToken: $TOKEN
EOF

sudo kubeadm join \
  --token "$TOKEN" "$MASTER:$MASTER_PORT" \
  --config /etc/packernetes/worker/kubeadm.conf
