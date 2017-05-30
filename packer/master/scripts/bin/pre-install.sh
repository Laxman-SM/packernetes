#!/usr/bin/env bash
#./pre-install.sh

set -e
set -x

sudo tee /root/.bash_aliases<<EOF
export KUBECONFIG=/etc/kubernetes/admin.conf

function kkpnodelost {
  kubectl get pods --all-namespaces | \
    grep NodeLost | \
      awk '{ print "kubectl delete pods --namespace " \$1 " --grace-period=0 --force " \$2; }' | \
        grep -v NAMESPACE
}

function kkp {
  kubectl get pods --all-namespaces | \
    grep -v ^kube-system | \
      awk '{ print "kubectl delete pods --namespace " \$1 " --grace-period=0 --force " \$2; }' | \
        grep -v NAMESPACE
}

function kkc {
  kubectl config view --minify
}

function kk {
  echo
  echo "#### #### #### PODS"
  kubectl get pods --all-namespaces -o wide
  echo
  echo "#### #### #### SERVICES"
  kubectl get svc --all-namespaces -o wide
  echo
  echo "#### #### #### INGRESSES"
  kubectl get ing --all-namespaces -o wide
  echo
  echo "#### #### #### NODES"
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

wget -SO- https://raw.githubusercontent.com/containous/traefik/master/examples/k8s/traefik.yaml | \
  sudo tee /root/INSTALL/traefik/traefik.yaml

wget -SO- https://raw.githubusercontent.com/containous/traefik/master/examples/k8s/traefik-rbac.yaml | \
  sudo tee /root/INSTALL/traefik/traefik-rbac.yaml

wget -SO- https://raw.githubusercontent.com/containous/traefik/master/examples/k8s/ui.yaml | \
  sudo tee /root/INSTALL/traefik/ui.yaml

# sanity check for downloaded files
for FILE in $(sudo find /root/INSTALL -type f -ipath '*.yaml'); do
  sudo test -s "$FILE"
done

for FILE in $(sudo find /root/INSTALL -type f -ipath '*.yml'); do
  sudo test -s "$FILE"
done

sudo git clone https://github.com/agabert/armory.git /root/INSTALL/armory

sudo git clone https://github.com/agabert/mesolcina.git /root/INSTALL/mesolcina

exit 0
