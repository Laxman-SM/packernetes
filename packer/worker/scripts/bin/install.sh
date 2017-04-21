#!/usr/bin/env bash

if [[ "" == "$TOKEN" ]]; then
  echo "ERROR: environment variable TOKEN not set"
  exit 1
fi

if [[ "" == "$MASTER" ]]; then
  echo "ERROR: environment variable MASTER not set"
  exit 1
fi

if [[ "" == "$MASTER_PORT" ]]; then
  MASTER_PORT="6443"
fi

sudo kubeadm join --token="$TOKEN" "$MASTER:$MASTER_PORT"

exit 0

