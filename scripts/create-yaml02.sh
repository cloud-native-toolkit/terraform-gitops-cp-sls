#!/usr/bin/env bash
SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)
CHART02_DIR=$(cd "${MODULE_DIR}/charts/ibm-sls-operator-instance"; pwd -P)
if [[ -z "${TMP_DIR}" ]]; then
  TMP_DIR="./.tmp"
fi
mkdir -p "${TMP_DIR}"


INGRESS="$1"
SLSNAMESPACE="$2"
MONGONAMESPACE="$3"
SVC="$4"
NAME="$5"
PORT="$6"
DEST_DIR="$7"

cat > "${TMP_DIR}/values.yaml" << EOL
slsinstance:
  name: sls
  spec:
    license:
      accept: true
    domain: ${INGRESS}
    mongo:
      configDb: admin
      nodes:
        - host: '$SVC.$MONGONAMESPACE.svc'
          port: ${PORT}
      secretName: sls-mongo-credentials
      authMechanism: DEFAULT
      retryWrites: true
    settings:
      auth:
        enforce: true
      compliance:
        enforce: true
      reconciliation:
        enabled: true
        reconciliationPeriod: 1800
      registration:
        open: true
      reporting:
        maxDailyReports: 90
        maxHourlyReports: 24
        maxMonthlyReports: 12
        reportGenerationPeriod: 3600
        samplingPeriod: 900
EOL
  mkdir -p "${DEST_DIR}"

  VALUES_FILE="values.yaml"
  cp "${TMP_DIR}/${VALUES_FILE}" "${CHART02_DIR}"
  cp -R "${CHART02_DIR}"/* "${DEST_DIR}"  
