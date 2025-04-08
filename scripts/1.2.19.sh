#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando seguridad del endpoint healthz y métricas del API Server"

# 1️⃣ Verificar los endpoints del API Server
echo "📡 Obteniendo los endpoints del Kubernetes API Server..."
oc -n openshift-kube-apiserver describe endpoints

# 2️⃣ Seleccionar el namespace del API Server
oc project openshift-kube-apiserver

# 3️⃣ Obtener el nombre del pod del API Server
POD=$(oc get pods -n openshift-kube-apiserver -l app=openshift-kube-apiserver -o jsonpath='{.items[0].metadata.name}')
echo "🔎 API Server Pod: $POD"

# 4️⃣ Obtener el puerto en el que está sirviendo métricas
PORT=$(oc get pods -n openshift-kube-apiserver -l app=openshift-kube-apiserver -o jsonpath='{.items[0].spec.containers[0].ports[0].hostPort}')
echo "🔎 API Server Metrics Port: $PORT"

# 5️⃣ Verificar acceso sin autenticación (debe devolver HTTP 403)
echo "🚨 Verificando acceso sin autenticación (debe fallar con 403 Forbidden)..."
UNAUTHENTICATED_ACCESS=$(oc rsh -n openshift-kube-apiserver $POD curl -s -o /dev/null -w "%{http_code}" https://localhost:$PORT/metrics -k)

if [ "$UNAUTHENTICATED_ACCESS" != "403" ]; then
    echo "❌ Fallo: El API Server permite acceso sin autenticación. Código HTTP: $UNAUTHENTICATED_ACCESS"
    exit 1
else
    echo "✅ Acceso sin autenticación correctamente bloqueado (HTTP 403)"
fi

# 6️⃣ Crear una Service Account para probar RBAC
echo "🛠️ Creando Service Account de prueba..."
oc create -n openshift-kube-apiserver sa permission-test-sa

# 7️⃣ Obtener el token de la Service Account
SA_TOKEN=$(oc sa -n openshift-kube-apiserver get-token permission-test-sa)

# 8️⃣ Verificar que la Service Account no puede acceder (debe devolver 403)
echo "🚨 Verificando que la Service Account no tenga acceso (debe fallar con 403 Forbidden)..."
SA_ACCESS=$(oc rsh -n openshift-kube-apiserver $POD curl -s -o /dev/null -w "%{http_code}" https://localhost:$PORT/metrics -H "Authorization: Bearer $SA_TOKEN" -k)

if [ "$SA_ACCESS" != "403" ]; then
    echo "❌ Fallo: La Service Account pudo acceder a las métricas. Código HTTP: $SA_ACCESS"
    exit 1
else
    echo "✅ La Service Account está correctamente bloqueada (HTTP 403)"
fi

# 9️⃣ Verificar que un administrador sí puede acceder
echo "🛠️ Verificando que un usuario administrador pueda acceder..."
CLUSTER_ADMIN_TOKEN=$(oc whoami -t)

ADMIN_ACCESS=$(oc rsh -n openshift-kube-apiserver $POD curl -s -o /dev/null -w "%{http_code}" https://localhost:$PORT/metrics -H "Authorization: Bearer $CLUSTER_ADMIN_TOKEN" -k)

if [ "$ADMIN_ACCESS" != "200" ]; then
    echo "❌ Fallo: El usuario administrador no pudo acceder a las métricas. Código HTTP: $ADMIN_ACCESS"
    exit 1
else
    echo "✅ El usuario administrador puede acceder a las métricas (HTTP 200)"
fi

# 🔄 Limpiar las configuraciones de prueba
echo "🧹 Eliminando Service Account de prueba..."
oc delete -n openshift-kube-apiserver sa permission-test-sa

# Eliminar variables de entorno
unset CLUSTER_ADMIN_TOKEN SA_TOKEN POD PORT

# 🎉 Si todas las verificaciones pasaron, mostrar éxito
echo "✅ Éxito: La configuración del API Server es segura y cumple con los requisitos de RBAC."
exit 0
