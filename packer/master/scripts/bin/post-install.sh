#!/usr/bin/env bash
#./post-install.sh
MASTER="${1}"
MASTER_PORT="${2:-6443}"

FLANNEL="/home/ubuntu/packernetes/master/scripts/conf/kube-flannel.yaml"
export KUBECONFIG="/home/ubuntu/kubernetes/admin.conf"

set -e

if [[ "" == "$MASTER" ]]; then
  MASTER="$HOSTNAME"
fi

kubectl apply \
  -f $FLANNEL \
  --server=https://$MASTER:$MASTER_PORT

exit 0

