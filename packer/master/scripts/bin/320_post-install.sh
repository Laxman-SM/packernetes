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
# WEAVE
#
kubectl apply -f /root/INSTALL/weave.yaml

#
# DASHBOARD
#
kubectl apply -f /root/INSTALL/kubernetes-dashboard.yaml

#
# TRAEFIK
#
kubectl apply -f /root/INSTALL/traefik/traefik-rbac.yaml
kubectl apply -f /root/INSTALL/traefik/traefik.yaml
kubectl apply -f /root/INSTALL/traefik/ui.yaml

#
# ARMORY
#
make -C /root/INSTALL/armory

#
# beacon
#
cd /root/INSTALL/beacon
make kubernetes

exit 0

