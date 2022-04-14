#!/bin/sh

ZEN_OPERATORS_NAMESPACE="${ZEN_OPERATORS_NAMESPACE}"
COMMON_SERVICES_NAMESPACE="${COMMON_SERVICES_NAMESPACE}"

echo "success 1"

oc get operandregistry common-service -n ${COMMON_SERVICES_NAMESPACE} -o json > /temp/operandregistry.json

echo "success 2"

jq '(.spec.operators[] | select(.name == "ibm-db2u-operator")).namespace = "${OPERATORS_NAMESPACE}"' /temp/operandregistry.json > /temp/operandregistry_new.json

echo "success 3"

oc apply -f /temp/operandregistry_new.json

echo "success 4"