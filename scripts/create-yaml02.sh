#!/usr/bin/env bash
SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)
CHART02_DIR=$(cd "${MODULE_DIR}/charts/ibm-sls-operator-instance"; pwd -P)



INGRESS="$1"
SLSNAMESPACE="$2"
SLSSTOR="$3"
MONGONAMESPACE="$4"
SVC="$5"
PODLIST=$(kubectl get pods --selector=app=mas-mongo-ce-svc -o=json -n mongo -o=jsonpath={.items..metadata.name})
PODLIST=($PODLIST)
PORT=$(kubectl get svc mas-mongo-ce-svc -n mongo -o=jsonpath='{.spec.ports[?(@.name=="mongodb")].port}')

cat > "${CHART02_DIR}/values.yaml" << EOL
apiVersion: sls.ibm.com/v1
kind: LicenseService
metadata:
  name: sls
  namespace: ${SLSNAMESPACE}
spec:
  license:
    accept: true
  domain: ${INGRESS}
  mongo:
    configDb: admin
    nodes:
$(for podname in "${PODLIST[@]}"; do echo "      - host: "$podname.$SVC.$MONGONAMESPACE.svc$'\n        port: '$PORT; done)
    secretName: sls-mongo-credentials
    authMechanism: DEFAULT
    retryWrites: true
    certificates:
    - alias: mongoca
      crt: |
$(kubectl get ConfigMap mas-mongo-ce-cert-map -n ${MONGONAMESPACE} -o jsonpath='{.data.ca\.crt}' | awk '{printf "        %s\n", $0}')
  rlks:
    storage:
      class: ${SLSSTOR}
      size: 20G
EOL
  mkdir -p "${DEST_DIR}"

  VALUES_CONTENT=${CHART02_DIR}"/values.yaml"
  VALUES_FILE="values.yaml"
  cp -R "${CHART02_DIR}"/* "${DEST_DIR}"  
  echo "${VALUES_CONTENT}" > "${DEST_DIR}${VALUES_FILE}"


#SLSKEY=$(kubectl get LicenseService sls -n ${SLSNAMESPACE} --output="jsonpath={..registrationKey}")
#echo ${SLSKEY} > ${TMP_DIR}/sls-key
