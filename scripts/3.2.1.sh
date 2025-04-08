#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando la configuración de auditoría mínima en OpenShift API Server"

# 1️⃣ Verificar que la política de auditoría esté habilitada
AUDIT_POLICY=$(oc get apiserver cluster -o json | jq .spec.audit.profile)

if [ "$AUDIT_POLICY" == "None" ]; then
    echo "❌ Fallo: La política de auditoría está deshabilitada."
    exit 1
else
    echo "✅ La política de auditoría está habilitada correctamente."
fi

# 2️⃣ Verificar la configuración del API Server de OpenShift
echo "🔎 Verificando la configuración del API Server de OpenShift..."
OPENSHIFT_API_CONFIG=$(oc get cm -n openshift-apiserver config -o json | jq -r '.data."config.yaml"' | jq .apiServerArguments)

if [ -z "$OPENSHIFT_API_CONFIG" ]; then
    echo "❌ Fallo: No se encuentra la configuración del API Server de OpenShift."
    exit 1
else
    echo "✅ Configuración del API Server de OpenShift encontrada."
fi

# 3️⃣ Verificar la configuración del API Server de Kubernetes
echo "🔎 Verificando la configuración del API Server de Kubernetes..."
KUBERNETES_API_CONFIG=$(oc get cm -n openshift-kube-apiserver config -o json | jq -r '.data."config.yaml"' | jq .apiServerArguments)

if [ -z "$KUBERNETES_API_CONFIG" ]; then
    echo "❌ Fallo: No se encuentra la configuración del API Server de Kubernetes."
    exit 1
else
    echo "✅ Configuración del API Server de Kubernetes encontrada."
fi

# 4️⃣ Verificar las políticas de auditoría
echo "🔎 Verificando las políticas de auditoría..."
OPENSHIFT_AUDIT_POLICY=$(oc get cm -n openshift-apiserver audit -o json | jq -r '.data."policy.yaml"')
KUBERNETES_AUDIT_POLICY=$(oc get cm -n openshift-kube-apiserver kube-apiserver-audit-policies -o json | jq -r '.data."policy.yaml"')

if [ -z "$OPENSHIFT_AUDIT_POLICY" ] || [ -z "$KUBERNETES_AUDIT_POLICY" ]; then
    echo "❌ Fallo: No se encuentran las políticas de auditoría."
    exit 1
else
    echo "✅ Políticas de auditoría de OpenShift y Kubernetes encontradas."
fi

# 5️⃣ Verificar los logs de auditoría de Kubernetes
echo "🔎 Verificando los logs de auditoría de Kubernetes..."
KUBERNETES_LOGS=$(oc adm node-logs --role=master --path=kube-apiserver/)

if [ -z "$KUBERNETES_LOGS" ]; then
    echo "❌ Fallo: No se encuentran los logs de auditoría de Kubernetes."
    exit 1
else
    echo "✅ Logs de auditoría de Kubernetes encontrados."
fi

# 6️⃣ Verificar los logs de auditoría de OpenShift
echo "🔎 Verificando los logs de auditoría de OpenShift..."
OPENSHIFT_LOGS=$(oc adm node-logs --role=master --path=openshift-apiserver/)

if [ -z "$OPENSHIFT_LOGS" ]; then
    echo "❌ Fallo: No se encuentran los logs de auditoría de OpenShift."
    exit 1
else
    echo "✅ Logs de auditoría de OpenShift encontrados."
fi

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: La política de auditoría está configurada correctamente y los logs están siendo generados."
exit 0
