#!/usr/bin/env bash

set -e
set -x

export KUBECONFIG=/etc/kubernetes/admin.conf

#
# disable RBAC
#
kubectl create clusterrolebinding permissive-binding \
  --clusterrole=cluster-admin \
  --user=admin \
  --user=kubelet \
  --group=system:serviceaccounts

#
# storage
#
kubectl apply -f /root/INSTALL/storage/storageclasses.yaml
kubectl patch storageclass default \
  -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

exit 0
