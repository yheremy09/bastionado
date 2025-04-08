#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que el parámetro --bind-address esté configurado correctamente en OpenShift API Server"

# 1️⃣ Verificar la configuración del puerto seguro (debe ser 10257)
SECURE_PORT=$(oc get configmaps config -n openshift-kube-controller-manager -ojson | \
    jq -r '.data["config.yaml"]' | \
    jq -r '.extendedArguments["secure-port"][]')

# Verificar que el puerto seguro esté configurado correctamente
if [ "$SECURE_PORT" != "10257" ]; then
    echo "❌ Fallo: El puerto seguro no está configurado correctamente. Valor detectado: $SECURE_PORT"
    exit 1
else
    echo "✅ Configuración correcta: El puerto seguro está configurado como $SECURE_PORT"
fi

# 2️⃣ Verificar que el endpoint de métricas está protegido con HTTP 403
echo "🔎 Verificando que el endpoint de métricas esté protegido contra accesos no autorizados..."

# Obtener el nombre del pod del Controller Manager
export POD=$(oc get pods -n openshift-kube-controller-manager -l app=kube-controller-manager -o jsonpath='{.items[0].metadata.name}')

# Intentar acceder al endpoint de métricas
METRICS_ACCESS=$(oc rsh -n openshift-kube-controller-manager -c kube-controller-manager $POD curl -s -o /dev/null -w "%{http_code}" https://localhost:10257/metrics -k)

# Verificar que se reciba un error HTTP 403
if [ "$METRICS_ACCESS" != "403" ]; then
    echo "❌ Fallo: El acceso al endpoint de métricas no está protegido correctamente. Código HTTP detectado: $METRICS_ACCESS"
    exit 1
else
    echo "✅ El endpoint de métricas está protegido correctamente con HTTP 403."
fi

# Limpiar las variables de entorno
unset POD

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: La configuración de --bind-address y la protección del endpoint de métricas son correctas."
exit 0
