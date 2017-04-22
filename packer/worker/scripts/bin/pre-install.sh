#!/usr/bin/env bash
#./pre-install.sh

set -e

sudo tee /etc/rc.local <<EOF
#!/usr/bin/env bash
echo '#'
echo '# setting up kubernetes worker node'
echo '#'

exec /home/ubuntu/packernetes/packer/worker/scripts/bin/install.sh

EOF

sudo chmod 0755 /etc/rc.local
sudo chown root:root /etc/rc.local

#
# get the docker images to improve startup time of kubernetes worker
#
for IMAGE in gcr.io/google_containers/kube-proxy-amd64:v${KUBERNETES_VERSION}
do
  sudo docker pull $IMAGE
done

exit 0

