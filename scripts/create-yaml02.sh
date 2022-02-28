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
SLSSTOR="$3"
MONGONAMESPACE="$4"
SVC="$5"
NAME="$6"
PORT="$7"
DEST_DIR="$8"

cat > "${TMP_DIR}/values.yaml" << EOL
slsinstance:
  name: ibm-sls-operator-instance
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
      certificates:
      - alias: mongoca
        crt: |
$(echo | awk -v ca_var="$CA_CRT" '{ printf ca_var; }' | sed 's/^/          /')
    rlks:
      storage:
        class: ${SLSSTOR}
        size: 20G
EOL
  mkdir -p "${DEST_DIR}"

  #VALUES_CONTENT=${CHART02_DIR}"/values.yaml"
  VALUES_FILE="values.yaml"
  cp "${TMP_DIR}/${VALUES_FILE}" "${CHART02_DIR}"
  cp -R "${CHART02_DIR}"/* "${DEST_DIR}"  
  #echo "${VALUES_CONTENT02}" > "${DEST_DIR}${VALUES_FILE}"


#SLSKEY=$(kubectl get LicenseService sls -n ${SLSNAMESPACE} --output="jsonpath={..registrationKey}")
#echo ${SLSKEY} > ${TMP_DIR}/sls-key
