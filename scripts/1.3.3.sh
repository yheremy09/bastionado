#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando la configuración de --service-account-private-key-file en OpenShift API Server"

# Obtener el valor de --service-account-private-key-file desde la ConfigMap
SERVICE_ACCOUNT_PRIVATE_KEY_FILE=$(oc get configmaps config -n openshift-kube-controller-manager -ojson | \
    jq -r '.data["config.yaml"]' | \
    jq -r '.extendedArguments["service-account-private-key-file"][]')

# Verificar si el valor es correcto
if [ "$SERVICE_ACCOUNT_PRIVATE_KEY_FILE" != "/etc/kubernetes/static-pod-resources/secrets/service-account-private-key/service-account.key" ]; then
    echo "❌ Fallo: --service-account-private-key-file no está configurado correctamente. Valor detectado: $SERVICE_ACCOUNT_PRIVATE_KEY_FILE"
    exit 1
else
    echo "✅ Configuración correcta: --service-account-private-key-file está configurado como $SERVICE_ACCOUNT_PRIVATE_KEY_FILE"
fi

# Finalizar con éxito si todo está correcto
exit 0
