#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que el API Scheduler esté protegido por RBAC"

# 1️⃣ Verificar los Endpoints del Scheduler
ENDPOINTS=$(oc -n openshift-kube-scheduler describe endpoints)

if [ -z "$ENDPOINTS" ]; then
    echo "❌ Fallo: No se encuentran los endpoints del Scheduler."
    exit 1
else
    echo "✅ Endpoints del Scheduler encontrados."
fi

# 2️⃣ Verificar que los parámetros bind-address y port no estén configurados
ARGS=$(oc -n openshift-kube-scheduler get cm kube-scheduler-pod -o json | jq -r '.data."pod.yaml"' | jq '.spec.containers[]|select(.name=="kube-scheduler")|.args')

if echo "$ARGS" | grep -q "bind-address"; then
    echo "❌ Fallo: El parámetro bind-address está configurado en el Scheduler."
    exit 1
fi

if echo "$ARGS" | grep -q "port"; then
    echo "❌ Fallo: El parámetro port está configurado en el Scheduler."
    exit 1
fi

echo "✅ El parámetro bind-address y port no están configurados."

# 3️⃣ Verificar que el endpoint de métricas está protegido por RBAC
echo "🔎 Verificando que el endpoint de métricas esté protegido por RBAC..."

# Cambiar al namespace del Scheduler
oc project openshift-kube-scheduler

# Obtener el nombre del pod y la IP del pod del Scheduler
export POD=$(oc get pods -l app=openshift-kube-scheduler -o jsonpath='{.items[0].metadata.name}')
export POD_IP=$(oc get pods -l app=openshift-kube-scheduler -o jsonpath='{.items[0].status.podIP}')
export PORT=$(oc get pod $POD -o jsonpath='{.spec.containers[0].livenessProbe.httpGet.port}')

# Verificar acceso no autenticado
UNAUTHENTICATED_ACCESS=$(oc rsh $POD curl -s -o /dev/null -w "%{http_code}" https://$POD_IP:$PORT/metrics -k)

if [ "$UNAUTHENTICATED_ACCESS" != "403" ]; then
    echo "❌ Fallo: El acceso no autenticado debe devolver 403 Forbidden. Código HTTP detectado: $UNAUTHENTICATED_ACCESS"
    exit 1
else
    echo "✅ Acceso no autenticado correctamente bloqueado con 403 Forbidden."
fi

# 4️⃣ Verificar que una Service Account no pueda acceder
echo "🛠️ Verificando que una Service Account sin permisos no pueda acceder..."

# Crear Service Account
oc create sa permission-test-sa
export SA_TOKEN=$(oc create token permission-test-sa)

# Verificar que la Service Account no pueda acceder
SERVICE_ACCOUNT_ACCESS=$(oc rsh $POD curl -s -o /dev/null -w "%{http_code}" https://$POD_IP:$PORT/metrics -H "Authorization: Bearer $SA_TOKEN" -k)

if [ "$SERVICE_ACCOUNT_ACCESS" != "403" ]; then
    echo "❌ Fallo: La Service Account debe recibir un error 403 Forbidden."
    exit 1
else
    echo "✅ La Service Account está correctamente bloqueada con 403 Forbidden."
fi

# 5️⃣ Verificar que un administrador pueda acceder
echo "🛠️ Verificando que un administrador del clúster pueda acceder..."

export CLUSTER_ADMIN_TOKEN=$(oc whoami -t)
ADMIN_ACCESS=$(oc rsh $POD curl -s -o /dev/null -w "%{http_code}" https://$POD_IP:$PORT/metrics -H "Authorization: Bearer $CLUSTER_ADMIN_TOKEN" -k)

if [ "$ADMIN_ACCESS" != "200" ]; then
    echo "❌ Fallo: El administrador del clúster no puede acceder a las métricas. Código HTTP: $ADMIN_ACCESS"
    exit 1
else
    echo "✅ El administrador del clúster puede acceder correctamente a las métricas (HTTP 200)."
fi

# 6️⃣ Limpiar la configuración de prueba
unset CLUSTER_ADMIN_TOKEN POD PORT SA_TOKEN POD_IP
oc delete sa permission-test-sa

# Finalizar con éxito si todo pasó
echo "✅ Éxito: El API Scheduler está protegido por RBAC correctamente."
exit 0
