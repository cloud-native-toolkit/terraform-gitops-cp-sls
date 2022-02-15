#!/usr/bin/env bash

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

export KUBECONFIG=$(cat .kubeconfig)
NAMESPACE=$(cat .namespace)
BRANCH="main"
SERVER_NAME="default"
TYPE="operators"
LAYER="2-services"
INSTANCE_NAME="ibm-sls-operator-instance"
COMPONENT_NAMES="ibm-sls-operator-subscription,ibm-sls-operator-instance"
#COMPONENT_NAME="ibm-sls-operator-subscription"

mkdir -p .testrepo

sleep 30s

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"
IFS=","
for COMPONENT_NAME  in $COMPONENT_NAMES;
do
if [[ ! -f "argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml" ]]; then
  echo "ArgoCD config missing - argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml"
  exit 1
fi

echo "Printing argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml"
cat "argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml"

if [[ ! -f "payload/${LAYER}/namespace/${NAMESPACE}/${COMPONENT_NAME}/values.yaml" ]]; then
  echo "Application values not found - payload/2-services/namespace/${NAMESPACE}/${COMPONENT_NAME}/values.yaml"
  exit 1
fi

echo "Printing payload/${LAYER}/namespace/${NAMESPACE}/${COMPONENT_NAME}/values.yaml"
cat "payload/${LAYER}/namespace/${NAMESPACE}/${COMPONENT_NAME}/values.yaml"
done
sleep 7m
count=0
until kubectl get namespace "${NAMESPACE}" 1> /dev/null 2> /dev/null || [[ $count -eq 20 ]]; do
  echo "Waiting for namespace: ${NAMESPACE}"
  count=$((count + 1))
  sleep 15
done

if [[ $count -eq 20 ]]; then
  echo "Timed out waiting for namespace: ${NAMESPACE}"
  exit 1
else
  echo "Found namespace: ${NAMESPACE}. Sleeping for 30 seconds to wait for everything to settle down"
  sleep 30
fi
kubectl get all -n "${NAMESPACE}"

#DEPLOYMENT="${INSTANCE_NAME}-${BRANCH}"
#DEPLOYMENT="${COMPONENT_NAME}-${BRANCH}"
#count=0
#until kubectl get deployment "${DEPLOYMENT}" -n "${NAMESPACE}" || [[ $count -eq 20 ]]; do
  #echo "Waiting for deployment/${DEPLOYMENT} in ${NAMESPACE}"
  #count=$((count + 1))
  #sleep 15
#done

#if [[ $count -eq 20 ]]; then
  #echo "Timed out waiting for deployment/${DEPLOYMENT} in ${NAMESPACE}"
  #kubectl get all -n "${NAMESPACE}"
  #exit 1
#fi

#kubectl rollout status "deployment/${DEPLOYMENT}" -n "${NAMESPACE}" || exit 1


cd ..
rm -rf .testrepo
