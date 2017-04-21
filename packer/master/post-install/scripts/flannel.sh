#!/bin/bash

set -e

export KUBECONFIG=/root/.kubectl-admin.conf

kubectl apply -f /root/post-install/conf/kube-flannel.yaml

