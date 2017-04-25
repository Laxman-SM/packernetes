#!/usr/bin/env bash
#./post-install.sh

set -e

export KUBECONFIG=/etc/kubernetes/admin.conf

# make sure this script runs after the workers have joined and are not NotReady
# https://github.com/kubernetes/kubernetes/issues/43815

kubectl apply -f /root/weave.yaml
kubectl apply -f /root/kubernetes-dashboard.yaml

kubectl apply -f /root/traefik/traefik-with-rbac.yaml
kubectl apply -f /root/traefik/ui.yaml

exit 0

