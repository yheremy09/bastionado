#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que la política de auditoría cubra las preocupaciones de seguridad clave"

# 1️⃣ Verificar la política de auditoría para el Kubernetes API Server
echo "🔎 Verificando la política de auditoría del Kubernetes API Server..."
KUBERNETES_AUDIT_POLICY=$(oc get configmap -n openshift-kube-apiserver kube-apiserver-audit-policies -o json | jq -r '.data."policy.yaml"')

if [[ -z "$KUBERNETES_AUDIT_POLICY" ]]; then
    echo "❌ Fallo: No se encuentra la política de auditoría para Kubernetes API Server."
    exit 1
else
    echo "✅ Política de auditoría para Kubernetes API Server encontrada."
fi

# 2️⃣ Verificar la política de auditoría para el OpenShift API Server
echo "🔎 Verificando la política de auditoría del OpenShift API Server..."
OPENSHIFT_AUDIT_POLICY=$(oc get configmap -n openshift-apiserver audit -o json | jq -r '.data."policy.yaml"')

if [[ -z "$OPENSHIFT_AUDIT_POLICY" ]]; then
    echo "❌ Fallo: No se encuentra la política de auditoría para OpenShift API Server."
    exit 1
else
    echo "✅ Política de auditoría para OpenShift API Server encontrada."
fi

# 3️⃣ Verificar que los recursos sensibles estén auditados a nivel de Metadata
echo "🔎 Verificando que los recursos sensibles como Secrets, ConfigMaps, y TokenReviews estén auditados a nivel de Metadata..."
if [[ ! "$KUBERNETES_AUDIT_POLICY" =~ "Secrets" || ! "$OPENSHIFT_AUDIT_POLICY" =~ "Secrets" ]]; then
    echo "❌ Fallo: Los recursos sensibles no están siendo auditados a nivel de Metadata."
    exit 1
else
    echo "✅ Los recursos sensibles están siendo auditados a nivel de Metadata."
fi

# 4️⃣ Verificar que las modificaciones a pods y despliegues estén auditadas a nivel de Request
echo "🔎 Verificando que las modificaciones a pods y despliegues estén auditadas a nivel de Request..."
if [[ ! "$KUBERNETES_AUDIT_POLICY" =~ "pods" || ! "$OPENSHIFT_AUDIT_POLICY" =~ "pods" ]]; then
    echo "❌ Fallo: Las modificaciones a pods no están siendo auditadas a nivel de Request."
    exit 1
else
    echo "✅ Las modificaciones a pods y despliegues están siendo auditadas correctamente."
fi

# 5️⃣ Verificar que el uso de pods/exec, pods/portforward, pods/proxy y services/proxy esté auditado
echo "🔎 Verificando que el uso de pods/exec, pods/portforward, pods/proxy y services/proxy esté auditado..."
if [[ ! "$KUBERNETES_AUDIT_POLICY" =~ "exec" || ! "$OPENSHIFT_AUDIT_POLICY" =~ "exec" ]]; then
    echo "❌ Fallo: El uso de pods/exec no está siendo auditado."
    exit 1
else
    echo "✅ El uso de pods/exec, pods/portforward, pods/proxy y services/proxy está siendo auditado correctamente."
fi

# 6️⃣ Verificar que la configuración de los logs de auditoría esté alineada con las políticas de retención de datos
echo "🔎 Verificando la configuración de los logs de auditoría..."
if [[ ! "$KUBERNETES_AUDIT_POLICY" =~ "logLevel" || ! "$OPENSHIFT_AUDIT_POLICY" =~ "logLevel" ]]; then
    echo "❌ Fallo: La configuración de los logs de auditoría no está alineada con las políticas de retención."
    exit 1
else
    echo "✅ La configuración de los logs de auditoría está alineada con las políticas de retención."
fi

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: La política de auditoría cubre las preocupaciones de seguridad clave."
exit 0
