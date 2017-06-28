#!/usr/bin/env bash

export AWS_ACCESS_KEY_ID=$PACKERNETES_AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$PACKERNETES_AWS_SECRET_ACCESS_KEY

# Canonical
OWNER=835512900189

aws ec2 describe-images --owners $OWNER | \
  jq '.Images[].Name' | \
    grep packernetes | \
      xargs -n1 echo | \
        sort -n
