#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando configuración de min-request-timeout en OpenShift API Server"

# Obtener el valor de min-request-timeout desde la ConfigMap
MIN_REQUEST_TIMEOUT=$(oc get configmap config -n openshift-kube-apiserver -ojson | jq -r '.data["config.yaml"]' | jq '.apiServerArguments["min-request-timeout"]')

# Verificar si el valor está presente y es válido
if [ -z "$MIN_REQUEST_TIMEOUT" ] || [ "$MIN_REQUEST_TIMEOUT" == "null" ]; then
    echo "❌ Fallo: min-request-timeout no está definido en la configuración del API Server."
    exit 1
else
    echo "✅ Configuración correcta: min-request-timeout está definido como $MIN_REQUEST_TIMEOUT."
fi

# Finalizar con éxito si todo está correcto
exit 0
