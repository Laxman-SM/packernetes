#!/bin/bash

KUBERNETES_VERSION="${1:-1.6.1}"
K8S_DNS_VERSION="${2:-1.14.1}"

cat >/root/.screenrc<<EOF
hardstatus alwayslastline

hardstatus string '%{= kG} MASTER [%= %{= kw}%?%-Lw%?%{r}[%{W}%n*%f %t%?{%u}%?%{r}]%{w}%?%+Lw%?%?%= %{g}] %{W}%{g}%{.w} screen %{.c} [%H]'
EOF

#
# get the docker images to improve startup time of kubernetes master
#
for IMAGE in gcr.io/google_containers/kube-apiserver-amd64:v${KUBERNETES_VERSION} \
  gcr.io/google_containers/kube-controller-manager-amd64:v${KUBERNETES_VERSION} \
  gcr.io/google_containers/kube-scheduler-amd64:v${KUBERNETES_VERSION} \
  gcr.io/google_containers/kube-proxy-amd64:v${KUBERNETES_VERSION} \
  gcr.io/google_containers/etcd-amd64:3.0.17 \
  gcr.io/google_containers/pause-amd64:3.0 \
  gcr.io/google_containers/k8s-dns-sidecar-amd64:${K8S_DNS_VERSION} \
  gcr.io/google_containers/k8s-dns-kube-dns-amd64:${K8S_DNS_VERSION} \
  gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:${K8S_DNS_VERSION}
do
  docker pull $IMAGE
done

exit 0

