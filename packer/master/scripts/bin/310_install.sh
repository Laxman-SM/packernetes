#!/usr/bin/env bash
#./install.sh

set -e
set -x

USER_DATA_URL="http://169.254.169.254/latest/user-data"

# if environment variable TOKEN has been set, do not overwrite it
if [[ "" == "$TOKEN" ]]; then
  TOKEN="$1"
fi

# $1 was empty
if [[ "" == "$TOKEN" ]]; then
  USER_DATA="$(wget --timeout=5 -qO- $USER_DATA_URL)"
  TOKEN="$(echo "$USER_DATA" | awk -F'|' {'print $1;'})"
fi

# user-data was empty or not reachable
if [[ "" == "$TOKEN" ]]; then
  export TOKEN="$(kubeadm token generate)"

  for i in $(seq 1 20); do
    sleep 1
    echo
    echo "WARNING using autogenerated token: [[$TOKEN]]"
    echo
  done
fi

# if environment variable MASTER_IP has been set, do not overwrite it
# otherwise try to load it from argv[2]
if [[ "" == "$MASTER_IP" ]]; then
  MASTER_IP="$2"
fi

sudo mkdir -pv /etc/packernetes/master

sudo tee /etc/packernetes/master/kubeadm.conf<<EOF
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
cloudProvider: aws

nodeName: $(hostname -f)

authorizationModes:
- Node
- RBAC

token: $TOKEN

apiServerCertSANs:
- localhost.localdomain
- localhost
- 127.0.0.1
- $(hostname -f)
- $(hostname)
- $(hostname -i)
- ec2-$(echo $MASTER_IP | sed 's,\.,-,g;').eu-central-1.compute.amazonaws.com
- $MASTER_IP

EOF

sudo kubeadm init --config /etc/packernetes/master/kubeadm.conf
