#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando configuración de service-account-lookup en OpenShift API Server"

# Obtener el valor de service-account-lookup desde la ConfigMap
SERVICE_ACCOUNT_LOOKUP=$(oc get configmap config -n openshift-kube-apiserver -ojson | jq -r '.data["config.yaml"]' | jq -r '.apiServerArguments."service-account-lookup"[]')

# Verificar si el valor está presente y configurado correctamente
if [ -z "$SERVICE_ACCOUNT_LOOKUP" ] || [ "$SERVICE_ACCOUNT_LOOKUP" == "null" ]; then
    echo "❌ Fallo: service-account-lookup no está definido en la configuración del API Server."
    exit 1
else
    echo "✅ Configuración correcta: service-account-lookup está definido como $SERVICE_ACCOUNT_LOOKUP."
fi

# Finalizar con éxito si todo está correcto
exit 0
