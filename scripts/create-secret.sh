#!/usr/bin/env bash

NAMESPACE="$1"
USER="$2"
PASS="$3"
DEST_DIR="$4"
PWD_SECRET_NAME="$5"

mkdir -p "${DEST_DIR}"

kubectl create secret generic "sls-mongo-credentials" \
  -n "${NAMESPACE}" \
  --from-literal="username=${USER}" \
  --from-literal="password=${PASS}" \
  --dry-run=client \
  --output=yaml > "${DEST_DIR}/${PWD_SECRET_NAME}.yaml"