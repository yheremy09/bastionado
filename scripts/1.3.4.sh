#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando la configuración de --root-ca-file en OpenShift API Server"

# Obtener el valor de --root-ca-file desde la ConfigMap
ROOT_CA_FILE=$(oc get configmaps config -n openshift-kube-controller-manager -ojson | \
    jq -r '.data["config.yaml"]' | \
    jq -r '.extendedArguments["root-ca-file"][]')

# Verificar si el valor es correcto
if [ "$ROOT_CA_FILE" != "/etc/kubernetes/static-pod-resources/configmaps/serviceaccount-ca/ca-bundle.crt" ]; then
    echo "❌ Fallo: --root-ca-file no está configurado correctamente. Valor detectado: $ROOT_CA_FILE"
    exit 1
else
    echo "✅ Configuración correcta: --root-ca-file está configurado como $ROOT_CA_FILE"
fi

# Finalizar con éxito si todo está correcto
exit 0
