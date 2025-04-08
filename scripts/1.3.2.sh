#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que el parámetro --use-service-account-credentials esté configurado como true en OpenShift API Server"

# Obtener el valor de --use-service-account-credentials desde la ConfigMap
SERVICE_ACCOUNT_CREDENTIALS=$(oc get configmaps config -n openshift-kube-controller-manager -ojson | \
    jq -r '.data["config.yaml"]' | \
    jq -r '.extendedArguments["use-service-account-credentials"][]')

# Verificar si el valor es true
if [ "$SERVICE_ACCOUNT_CREDENTIALS" != "true" ]; then
    echo "❌ Fallo: --use-service-account-credentials no está configurado como true. Valor detectado: $SERVICE_ACCOUNT_CREDENTIALS"
    exit 1
else
    echo "✅ Configuración correcta: --use-service-account-credentials está configurado como true."
fi

# Finalizar con éxito si todo está correcto
exit 0
