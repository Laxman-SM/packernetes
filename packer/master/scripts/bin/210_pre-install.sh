#!/usr/bin/env bash

set -e
set -x

sudo tee /root/.bash_aliases<<EOF
export KUBECONFIG=/etc/kubernetes/admin.conf

function kkxx {
  kubectl get pods --all-namespaces | \
    grep -v Running | \
      grep -v NAMESPACE | \
        awk '{ print "kubectl delete pods --namespace " \$1 " --grace-period=0 --force " \$2; }'
}

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

function icl {
  for POD in $(kubectl get pods --all-namespaces | grep traefik-ingress | awk '{print $2;}'); do
    echo "### $POD ###"
    kubectl --namespace kube-system logs $POD | awk '{print "'$POD'::" $0;}'
  done | \
    grep -v 'Skipping event from kubernetes' | \
    grep -v 'Received event from kubernetes' | \
    grep -v 'code: 200'
}

function kk {
  kubectl get all --all-namespaces -o wide
  echo
  echo "### ingress ###"
  kubectl get ingress --all-namespaces -o wide

  echo
  echo "### nodes ###"
  kubectl get nodes

  echo
  echo "### pvc ###"
  kubectl get pvc
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

sudo git clone https://github.com/agabert/beacon.git /root/INSTALL/beacon

sudo mkdir -pv /root/INSTALL/storage

sudo tee /root/INSTALL/storage/storageclasses.yaml<<EOF
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: alex1storageclass
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
EOF

sudo tee /root/INSTALL/storage/pvc.yaml<<EOF
{
  "kind": "PersistentVolumeClaim",
  "apiVersion": "v1",
  "metadata": {
    "name": "alex1claim",
    "annotations": {
        "volume.beta.kubernetes.io/storage-class": "alex1storageclass"
    }
  },
  "spec": {
    "accessModes": [
      "ReadWriteOnce"
    ],
    "resources": {
      "requests": {
        "storage": "10Gi"
      }
    }
  }
}
EOF

sudo tee /root/INSTALL/storage/nginx.yaml<<EOF
kind: Pod
apiVersion: v1
metadata:
  name: task-pv-pod
spec:
  volumes:
    - name: alex1volume
      persistentVolumeClaim:
       claimName: alex1claim
  containers:
    - name: task-pv-container
      image: nginx
      ports:
        - containerPort: 80
          name: "http-server"
      volumeMounts:
      - mountPath: "/usr/share/nginx/html"
        name: alex1volume
EOF

exit 0

