#!/usr/bin/env bash
#./install.sh

set -e

USER_DATA_URL="http://169.254.169.254/latest/user-data"
USER_DATA="$(wget -qO- $USER_DATA_URL)"

if [[ "" == "$TOKEN" ]]; then
  TOKEN="$(echo "$USER_DATA" | awk -F'|' {'print $1;'})"
fi

if [[ "" == "$MASTER" ]]; then
  MASTER="$(echo "$USER_DATA" | awk -F'|' {'print $2;'})"
fi

if [[ "" == "$MASTER_PORT" ]]; then
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

sudo kubeadm join --token "$TOKEN" "$MASTER:$MASTER_PORT"

