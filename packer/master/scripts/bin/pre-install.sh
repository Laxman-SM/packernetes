#!/usr/bin/env bash
#./pre-install.sh

set -e

sudo tee /root/.bash_aliases<<EOF
export KUBECONFIG=/etc/kubernetes/admin.conf
alias kk="kubectl get pods --all-namespaces -o wide; echo; kubectl get nodes"
EOF

wget -SO- https://git.io/weave-kube-1.6 | \
  sudo tee /root/weave.yaml

wget -SO- https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml | \
  sudo tee /root/kubernetes-dashboard.yaml

sudo mkdir -pv /root/traefik

wget -SO- https://raw.githubusercontent.com/containous/traefik/master/examples/k8s/traefik-with-rbac.yaml | \
  sudo tee /root/traefik/traefik-with-rbac.yaml

wget -SO- https://raw.githubusercontent.com/containous/traefik/master/examples/k8s/ui.yaml | \
  sudo tee /root/traefik/ui.yaml

exit 0

