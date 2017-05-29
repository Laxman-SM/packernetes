#!/usr/bin/env bash
#./post-install.sh

set -e
set -x

export KUBECONFIG=/etc/kubernetes/admin.conf

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
# install, enable and start the kubectl proxy systemd services
#
# make -C /root/INSTALL/mesolcina
#

exit 0
