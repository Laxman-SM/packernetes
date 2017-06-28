#!/usr/bin/env bash

export AWS_ACCESS_KEY_ID=$PACKERNETES_AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$PACKERNETES_AWS_SECRET_ACCESS_KEY

# Canonical
OWNER=099720109477

# Xenial
VERSION=16.04

for LATEST in $( \
  aws ec2 describe-images \
    --owners "$OWNER" \
    --filters "Name=name,Values=*hvm*ssd*-$VERSION*" | \
      jq '.Images[].CreationDate' | \
        sort -nr | \
          head -n1 | \
            xargs -n1 echo); do
  aws ec2 describe-images \
    --owners $OWNER \
    --filters "Name=name,Values=*hvm*ssd*-$VERSION*" | \
      jq '.Images[] | select(.CreationDate | contains("'$LATEST'")) | .ImageId' | \
        xargs -n1 echo
done

