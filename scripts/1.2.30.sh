#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando configuración de etcd-cafile en OpenShift API Server"

# Obtener el valor de etcd-cafile desde la ConfigMap
ETCD_CA_FILE=$(oc get configmap config -n openshift-kube-apiserver -ojson | \
    jq -r '.data["config.yaml"]' | \
    jq -r '.apiServerArguments["etcd-cafile"]')

# Verificar si el valor está presente y no es nulo
if [ -z "$ETCD_CA_FILE" ] || [ "$ETCD_CA_FILE" == "null" ]; then
    echo "❌ Fallo: etcd-cafile no está definido en la configuración del API Server."
    exit 1
else
    echo "✅ Configuración correcta: etcd-cafile está configurado como $ETCD_CA_FILE."
fi

# Finalizar con éxito si todo está correcto
exit 0
