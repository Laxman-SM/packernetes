#!/usr/bin/env bash
#./post-install.sh

set -e

export KUBECONFIG=/etc/kubernetes/admin.conf

# https://github.com/kubernetes/kubernetes/issues/43815
for i in $(seq 1 200); do
  echo -n '.'
  sleep 1
done

kubectl apply -f /root/weave.yaml
kubectl apply -f /root/kubernetes-dashboard.yaml

kubectl apply -f /root/traefik/traefik-with-rbac.yaml
kubectl apply -f /root/traefik/ui.yaml

exit 0

