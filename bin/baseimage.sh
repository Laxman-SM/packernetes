#!/usr/bin/env bash

OWNERS="${1:-886464464894}"
FILTER="${2:-base image}"

export AWS_ACCESS_KEY_ID=$PACKERNETES_AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$PACKERNETES_AWS_SECRET_ACCESS_KEY

for IMAGE in $(aws ec2 describe-images --owners "$OWNERS" | jq '.Images[].ImageId' | xargs -n1 echo); do
  NAME="$(aws ec2 describe-images --owners "$OWNERS" --filters "Name=image-id,Values=$IMAGE" | jq '.Images[].Name')"
  echo "$NAME;$IMAGE"
done | grep -- "$FILTER" | sort -n | tail -n1 | awk -F';' '{print $2;}'

