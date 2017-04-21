#!/bin/bash

KUBECTL="/root/.kubectl-admin.conf"

set -e

cp /etc/kubernetes/admin.conf $KUBECTL
chown root:root $KUBECTL

