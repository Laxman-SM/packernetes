#!/usr/bin/env bash

set -e
set -x

sudo tee /etc/rc.local <<EOF
#!/usr/bin/env bash
echo '#'
echo '# setting up kubernetes worker node'
echo '#'

exec /home/ubuntu/packernetes/worker/scripts/bin/310_install.sh

EOF

sudo chmod 0755 /etc/rc.local
sudo chown root:root /etc/rc.local

sudo mkdir -pv /data

exit 0
