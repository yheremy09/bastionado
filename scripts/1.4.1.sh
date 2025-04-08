#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que los endpoints healthz del Scheduler estén protegidos por RBAC"

# 1️⃣ Verificar la configuración de livenessProbe
LIVENESS_PROBE=$(oc -n openshift-kube-scheduler get cm kube-scheduler-pod -o json | jq -r '.data."pod.yaml"' | jq '.spec.containers[].livenessProbe')

if [[ "$LIVENESS_PROBE" != *"healthz"* ]]; then
    echo "❌ Fallo: livenessProbe no está configurado con el endpoint /healthz."
    exit 1
else
    echo "✅ livenessProbe está configurado correctamente con el endpoint /healthz."
fi

# 2️⃣ Verificar la configuración de readinessProbe
READINESS_PROBE=$(oc -n openshift-kube-scheduler get cm kube-scheduler-pod -o json | jq -r '.data."pod.yaml"' | jq '.spec.containers[].readinessProbe')

if [[ "$READINESS_PROBE" != *"healthz"* ]]; then
    echo "❌ Fallo: readinessProbe no está configurado con el endpoint /healthz."
    exit 1
else
    echo "✅ readinessProbe está configurado correctamente con el endpoint /healthz."
fi

# 3️⃣ Verificar los endpoints del Scheduler
ENDPOINTS=$(oc -n openshift-kube-scheduler describe endpoints)

if [ -z "$ENDPOINTS" ]; then
    echo "❌ Fallo: No se encuentran los endpoints del Scheduler."
    exit 1
else
    echo "✅ Endpoints del Scheduler encontrados."
fi

# 4️⃣ Verificar que los endpoints están protegidos por RBAC
echo "🔎 Verificando que RBAC esté habilitado y proteja los endpoints..."

# Cambiar al namespace del Scheduler
oc project openshift-kube-scheduler

# Obtener el nombre del pod y el puerto
export POD=$(oc get pods -l app=kube-scheduler -o jsonpath='{.items[0].metadata.name}')
export PORT=$(oc get pod $POD -o jsonpath='{.spec.containers[0].livenessProbe.httpGet.port}')

# Verificar acceso no autenticado
UNAUTHENTICATED_ACCESS=$(oc rsh $POD curl -s -o /dev/null -w "%{http_code}" https://localhost:$PORT/metrics -k)

if [ "$UNAUTHENTICATED_ACCESS" != "403" ]; then
    echo "❌ Fallo: El acceso no autenticado debe devolver 403 Forbidden. Código HTTP detectado: $UNAUTHENTICATED_ACCESS"
    exit 1
else
    echo "✅ Acceso no autenticado correctamente bloqueado con 403 Forbidden."
fi

# 5️⃣ Verificar que una Service Account no pueda acceder
echo "🛠️ Verificando que una Service Account sin permisos no pueda acceder..."

# Crear Service Account
oc create sa permission-test-sa
export SA_TOKEN=$(oc create token permission-test-sa)

# Verificar que la Service Account no pueda acceder
SERVICE_ACCOUNT_ACCESS=$(oc rsh $POD curl -s -o /dev/null -w "%{http_code}" https://localhost:$PORT/metrics -H "Authorization: Bearer $SA_TOKEN" -k)

if [ "$SERVICE_ACCOUNT_ACCESS" != "403" ]; then
    echo "❌ Fallo: La Service Account debe recibir un error 403 Forbidden."
    exit 1
else
    echo "✅ La Service Account está correctamente bloqueada con 403 Forbidden."
fi

# 6️⃣ Verificar que un administrador pueda acceder
echo "🛠️ Verificando que un administrador del clúster pueda acceder..."

export CLUSTER_ADMIN_TOKEN=$(oc whoami -t)
ADMIN_ACCESS=$(oc rsh $POD curl -s -o /dev/null -w "%{http_code}" https://localhost:$PORT/metrics -H "Authorization: Bearer $CLUSTER_ADMIN_TOKEN" -k)

if [ "$ADMIN_ACCESS" != "200" ]; then
    echo "❌ Fallo: El administrador del clúster no puede acceder a las métricas. Código HTTP: $ADMIN_ACCESS"
    exit 1
else
    echo "✅ El administrador del clúster puede acceder correctamente a las métricas (HTTP 200)."
fi

# 7️⃣ Limpiar la configuración de prueba
unset CLUSTER_ADMIN_TOKEN POD PORT SA_TOKEN
oc delete sa permission-test-sa

# Finalizar con éxito si todo pasó
echo "✅ Éxito: Los endpoints healthz del Scheduler están protegidos por RBAC correctamente."
exit 0

