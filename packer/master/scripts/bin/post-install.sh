#!/usr/bin/env bash
#./post-install.sh

set -e

export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl apply -f /root/weave.yaml
kubectl apply -f /root/kubernetes-dashboard.yaml

kubectl apply -f /root/traefik/traefik-with-rbac.yaml
kubectl apply -f /root/traefik/ui.yaml

exit 0

