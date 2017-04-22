#!/usr/bin/env bash
#./post-install.sh

# this needs to be called using sudo!

export KUBECONFIG="/etc/kubernetes/admin.conf"

set -e

export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f https://git.io/weave-kube-1.6
kubectl create -f https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml

exit 0

