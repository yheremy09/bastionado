#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando configuración de audit-log-maxbackup en OpenShift API Server"

# Obtener el valor de audit-log-maxbackup desde la ConfigMap
AUDIT_LOG_MAXBACKUP=$(oc get configmap config -n openshift-kube-apiserver -ojson | jq -r '.data["config.yaml"]' | jq -r '.apiServerArguments["audit-log-maxbackup"][]?')

# Comprobar si audit-log-maxbackup está presente y no es nulo
if [ -z "$AUDIT_LOG_MAXBACKUP" ] || [ "$AUDIT_LOG_MAXBACKUP" == "null" ]; then
    echo "❌ Fallo: audit-log-maxbackup no está definido en la configuración del API Server."
    exit 1
fi

# Mostrar el valor obtenido
echo "✅ Configuración correcta: audit-log-maxbackup está definido como $AUDIT_LOG_MAXBACKUP"
exit 0

