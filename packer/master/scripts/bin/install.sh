#!/usr/bin/env bash
#./install.sh

set -e

USER_DATA_URL="http://169.254.169.254/latest/user-data"
USER_DATA="$(wget -qO- $USER_DATA_URL)"

if [[ "" == "$TOKEN" ]]; then
  TOKEN="$(echo "$USER_DATA" | awk -F'|' {'print $1;'})"
fi

if [[ "" == "$FQDN" ]]; then
  FQDN="$(echo "$USER_DATA" | awk -F'|' {'print $2;'})"
fi

if [[ "" == "$TOKEN" ]]; then
  export TOKEN="$(kubeadm token generate)"

  echo "WARNING"
  echo "WARNING you did not provide a token"
  echo "WARNING"
  echo "WARNING we checked the environment variable TOKEN and also $USER_DATA_URL"
  echo "WARNING"
  echo "WARNING we will now use an autogenerated token: [[$TOKEN]]"
  echo "WARNING"
fi

if [[ "" == "$FQDN" ]]; then
  APISERVER_CERT_EXTRA_SANS=""
else
  APISERVER_CERT_EXTRA_SANS="--apiserver-cert-extra-sans=$FQDN"
fi

sudo kubeadm init --token "$TOKEN" $APISERVER_CERT_EXTRA_SANS

exit 0

