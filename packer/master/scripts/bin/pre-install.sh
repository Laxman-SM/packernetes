#!/usr/bin/env bash
#./pre-install.sh

set -e

sudo tee /root/.bash_aliases<<EOF
export KUBECONFIG=/etc/kubernetes/admin.conf

function kkc {
  kubectl config view --minify
}

function kk {
  kubectl get pods --all-namespaces -o wide
  echo
  kubectl get nodes
}

function kkl {
  while(true); do
    kk
    echo
    date
    echo
    sleep 1
  done
}
EOF

sudo mkdir -pv /root/INSTALL

wget -SO- https://git.io/weave-kube-1.6 | \
  sudo tee /root/INSTALL/weave.yaml

wget -SO- https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml | \
  sudo tee /root/INSTALL/kubernetes-dashboard.yaml

sudo mkdir -pv /root/INSTALL/traefik

wget -SO- https://raw.githubusercontent.com/containous/traefik/master/examples/k8s/traefik-with-rbac.yaml | \
  sudo tee /root/INSTALL/traefik/traefik-with-rbac.yaml

wget -SO- https://raw.githubusercontent.com/containous/traefik/master/examples/k8s/ui.yaml | \
  sudo tee /root/INSTALL/traefik/ui.yaml

wget -SO- https://kubernetes-helm.storage.googleapis.com/helm-v2.4.0-linux-amd64.tar.gz | \
  sudo tar -C /tmp -xzvpf -

sudo cp -avpx /tmp/linux-amd64/helm /usr/local/bin/helm
sudo chown root:root /usr/local/bin/helm
sudo chmod 0755 /usr/local/bin/helm

sudo git clone https://github.com/agabert/armory.git /root/INSTALL/armory

sudo git clone https://github.com/agabert/mesolcina.git /root/INSTALL/mesolcina

exit 0

