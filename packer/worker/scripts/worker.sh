#!/bin/bash

KUBERNETES_VERSION="${1:-1.6.1}"
K8S_DNS_VERSION="${2:-1.14.1}"

cat >/root/.screenrc<<EOF
hardstatus alwayslastline

hardstatus string '%{= kG} WORKER [%= %{= kw}%?%-Lw%?%{r}[%{W}%n*%f %t%?{%u}%?%{r}]%{w}%?%+Lw%?%?%= %{g}] %{W}%{g}%{.w} screen %{.c} [%H]'
EOF

#
# get the docker images to improve startup time of kubernetes worker
#
for IMAGE in gcr.io/google_containers/kube-proxy-amd64:v${KUBERNETES_VERSION}
do
  docker pull $IMAGE
done

cat >/etc/rc.local<<EOF
#!/bin/bash -v
echo '#'
echo '# running user-data'
echo '#'
wget -qO- http://169.254.169.254/latest/user-data | /bin/bash
exit 0
EOF

chmod 0755 /etc/rc.local

exit 0
