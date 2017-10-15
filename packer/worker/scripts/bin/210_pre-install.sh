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

sudo sed -i 's,worker image,WORKER image,g;' /root/.screenrc

sudo cp /root/.screenrc /home/ubuntu/.screenrc
sudo chown ubuntu: /home/ubuntu/.screenrc

sudo tee /etc/rc.local <<EOF
#!/usr/bin/env bash
echo '#'
echo '# setting up kubernetes worker node'
echo '#'

echo 1 >/proc/sys/net/ipv6/conf/all/disable_ipv6

exec /home/ubuntu/packernetes/worker/scripts/bin/310_install.sh

EOF

sudo chmod 0755 /etc/rc.local
sudo chown root:root /etc/rc.local

sudo mkdir -pv /data

exit 0

