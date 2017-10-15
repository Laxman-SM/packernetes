#!/usr/bin/env bash

OWNER="${1:-886464464894}"

export AWS_ACCESS_KEY_ID=$PACKERNETES_AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$PACKERNETES_AWS_SECRET_ACCESS_KEY

for LATEST in $( \
  aws ec2 describe-images \
    --owners "$OWNER" \
    --filters "Name=name,Values=*packernetes*base*image*" | \
      jq '.Images[].CreationDate' | \
        sort -nr | \
          head -n1 | \
            xargs -n1 echo); do
  aws ec2 describe-images \
    --owners "$OWNER" \
    --filters "Name=name,Values=*packernetes*base*image*" | \
      jq '.Images[] | select(.CreationDate | contains("'$LATEST'")) | .ImageId' | \
        xargs -n1 echo
done
