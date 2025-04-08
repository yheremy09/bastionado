#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando configuración de serviceAccountPublicKeyFiles en OpenShift API Server"

# Obtener los valores de serviceAccountPublicKeyFiles desde la ConfigMap
SERVICE_ACCOUNT_PUBLIC_KEY_FILES=$(oc get configmap config -n openshift-kube-apiserver -ojson | \
    jq -r '.data["config.yaml"]' | \
    jq -r '.serviceAccountPublicKeyFiles[]')

# Verificar si el valor está presente y no es nulo
if [ -z "$SERVICE_ACCOUNT_PUBLIC_KEY_FILES" ] || [ "$SERVICE_ACCOUNT_PUBLIC_KEY_FILES" == "null" ]; then
    echo "❌ Fallo: serviceAccountPublicKeyFiles no está definido en la configuración del API Server."
    exit 1
else
    echo "✅ Configuración correcta: serviceAccountPublicKeyFiles está definido como $SERVICE_ACCOUNT_PUBLIC_KEY_FILES."
fi

# Finalizar con éxito si todo está correcto
exit 0
