#!/bin/bash

TOKEN_AUTH_CHECK=$( (oc get configmap config -n openshift-kube-apiserver -ojson 2>/dev/null | jq -r '.data["config.yaml"]' | jq '.apiServerArguments' | grep "token-auth-file") || (oc get configmap config -n openshift-apiserver -ojson 2>/dev/null | jq -r '.data["config.yaml"]' | jq '.apiServerArguments' | grep "token-auth-file") || (oc get kubeapiservers.operator.openshift.io cluster -o json 2>/dev/null | jq '.spec.observedConfig.apiServerArguments' | grep "token-auth-file") )

BASIC_AUTH_CHECK=$( (oc -n openshift-kube-apiserver get cm config -o yaml 2>/dev/null | grep "basic-auth") || (oc -n openshift-apiserver get cm config -o yaml 2>/dev/null | grep "basic-auth") )

AUTH_OPERATOR_STATUS=$(oc get clusteroperator authentication --no-headers 2>/dev/null | awk '{print $3}')

if [[ -n "$TOKEN_AUTH_CHECK" ]]; then echo "Fallo en 1.2.3 - Se detectó el uso de --token-auth-file"; exit 1; fi
if [[ -n "$BASIC_AUTH_CHECK" ]]; then echo "Fallo en 1.2.3 - Se detectó autenticación básica habilitada"; exit 1; fi
if [[ "$AUTH_OPERATOR_STATUS" != "True" ]]; then echo "Fallo en 1.2.3 - El operador de autenticación no está disponible"; exit 1; fi

echo "Éxito en 1.2.3"
exit 0
