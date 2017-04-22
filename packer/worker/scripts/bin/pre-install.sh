#!/usr/bin/env bash
#./pre-install.sh

set -e

sudo tee /etc/rc.local <<EOF
#!/usr/bin/env bash
echo '#'
echo '# setting up kubernetes worker node'
echo '#'

test -f /home/ubuntu/packernetes/packer/worker/scripts/bin/install.sh && \
  exec /home/ubuntu/packernetes/packer/worker/scripts/bin/install.sh

EOF

sudo chmod 0755 /etc/rc.local
sudo chown root:root /etc/rc.local

exit 0

