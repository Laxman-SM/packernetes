#!/usr/bin/env bash

set -e
set -x

if [[ "" == "$AMI_NAME" ]]; then
  echo "ERROR: environment variable AMI_NAME is not set"
  exit 1
fi

if [[ "" == "$IMAGE_TYPE" ]]; then
  echo "ERROR: environment variable IMAGE_TYPE is not set"
  exit 1
fi

#
# screenrc
#
sudo tee /root/.screenrc<<EOF
hardstatus alwayslastline
hardstatus string '%{= kG} $AMI_NAME [%= %{= kw}%?%-Lw%?%{r}[%{W}%n*%f %t%?{%u}%?%{r}]%{w}%?%+Lw%?%?%= %{g}] %{W}%{g}%{.w} $IMAGE_TYPE %{.c} [%H]'
EOF

sudo sed -i 's,master image,MASTER image,g;' /root/.screenrc

sudo cp /root/.screenrc /home/ubuntu/.screenrc
sudo chown ubuntu: /home/ubuntu/.screenrc


sudo tee /root/.bash_aliases<<EOF
export KUBECONFIG=/etc/kubernetes/admin.conf

function kubelet_status {
  PAGER=cat systemctl status -l kubelet
}

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
  echo "### storage classes ###"
  kubectl get storageclasses

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

sudo mkdir -pv /root/INSTALL/storage
sudo mkdir -pv /root/INSTALL/storagetest

sudo tee /root/INSTALL/storage/storageclasses.yaml<<EOF
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: default
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
EOF

sudo tee /root/INSTALL/storagetest/pvc.yaml<<EOF
{
  "kind": "PersistentVolumeClaim",
  "apiVersion": "v1",
  "metadata": {
    "name": "alex1claim",
    "annotations": {
        "volume.beta.kubernetes.io/storage-class": "default"
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

sudo tee /root/INSTALL/storagetest/nginx.yaml<<EOF
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
