#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando configuración y existencia del log de auditoría en OpenShift API Server"

# 1️⃣ Verificar el audit-log-path en Kubernetes API Server
KUBE_AUDIT_PATH=$(oc get configmap config -n openshift-kube-apiserver -ojson | jq -r '.data["config.yaml"]' | jq -r '.apiServerArguments["audit-log-path"]')

if [ "$KUBE_AUDIT_PATH" != '["/var/log/kube-apiserver/audit.log"]' ]; then
    echo "❌ Fallo: El path de auditoría en Kubernetes API Server no está correctamente configurado. Valor detectado: $KUBE_AUDIT_PATH"
    exit 1
else
    echo "✅ Configuración correcta del audit-log-path en Kubernetes API Server: $KUBE_AUDIT_PATH"
fi

# 2️⃣ Verificar que el archivo de auditoría existe en Kubernetes API Server
export POD=$(oc get pods -n openshift-kube-apiserver -l app=openshift-kube-apiserver -o jsonpath='{.items[0].metadata.name}')

if ! oc rsh -n openshift-kube-apiserver -c kube-apiserver $POD ls /var/log/kube-apiserver/audit.log &>/dev/null; then
    echo "❌ Fallo: El archivo de auditoría /var/log/kube-apiserver/audit.log no existe en el Kubernetes API Server."
    exit 1
else
    echo "✅ El archivo de auditoría en Kubernetes API Server está presente."
fi

# 3️⃣ Verificar el audit-log-path en OpenShift API Server
OPENSHIFT_AUDIT_PATH=$(oc get configmap config -n openshift-apiserver -ojson | jq -r '.data["config.yaml"]' | jq -r '.apiServerArguments["audit-log-path"]')

if [ "$OPENSHIFT_AUDIT_PATH" != '["/var/log/openshift-apiserver/audit.log"]' ]; then
    echo "❌ Fallo: El path de auditoría en OpenShift API Server no está correctamente configurado. Valor detectado: $OPENSHIFT_AUDIT_PATH"
    exit 1
else
    echo "✅ Configuración correcta del audit-log-path en OpenShift API Server: $OPENSHIFT_AUDIT_PATH"
fi

# 4️⃣ Verificar que el archivo de auditoría existe en OpenShift API Server
export POD=$(oc get pods -n openshift-apiserver -l apiserver=true -o jsonpath='{.items[0].metadata.name}')

if ! oc rsh -n openshift-apiserver $POD ls /var/log/openshift-apiserver/audit.log &>/dev/null; then
    echo "❌ Fallo: El archivo de auditoría /var/log/openshift-apiserver/audit.log no existe en el OpenShift API Server."
    exit 1
else
    echo "✅ El archivo de auditoría en OpenShift API Server está presente."
fi

# 🎉 Si todas las verificaciones pasaron, mostrar éxito
echo "✅ Éxito: La configuración de auditoría y los archivos de log están correctamente configurados en OpenShift."
exit 0
