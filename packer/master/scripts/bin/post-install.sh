#!/usr/bin/env bash
#./post-install.sh

FLANNEL="/home/ubuntu/packernetes/master/scripts/conf/kube-flannel.yaml"

export KUBECONFIG="/home/ubuntu/kubernetes/admin.conf"

set -e

if [[ "" == "$MASTER" ]]; then
  MASTER="$HOSTNAME"
fi

if [[ "" == "$MASTER_PORT" ]]; then
  MASTER_PORT="6443"
fi

kubectl apply \
  -f $FLANNEL \
  --server=https://$MASTER:$MASTER_PORT

exit 0

