#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando la configuración de TLS para el API Server en OpenShift"

# 1️⃣ Verificar el archivo de certificado tls-cert-file
TLS_CERT_FILE=$(oc get configmap config -n openshift-kube-apiserver -ojson | \
    jq -r '.data["config.yaml"]' | \
    jq -r '.apiServerArguments."tls-cert-file"[]')

# Verificar si el archivo es correcto
if [ "$TLS_CERT_FILE" != "/etc/kubernetes/static-pod-certs/secrets/service-network-serving-certkey/tls.crt" ]; then
    echo "❌ Fallo: tls-cert-file no está configurado correctamente. Valor detectado: $TLS_CERT_FILE"
    exit 1
else
    echo "✅ Configuración correcta: tls-cert-file está configurado como $TLS_CERT_FILE"
fi

# 2️⃣ Verificar el archivo de clave tls-private-key-file
TLS_PRIVATE_KEY_FILE=$(oc get configmap config -n openshift-kube-apiserver -ojson | \
    jq -r '.data["config.yaml"]' | \
    jq -r '.apiServerArguments."tls-private-key-file"[]')

# Verificar si el archivo es correcto
if [ "$TLS_PRIVATE_KEY_FILE" != "/etc/kubernetes/static-pod-certs/secrets/service-network-serving-certkey/tls.key" ]; then
    echo "❌ Fallo: tls-private-key-file no está configurado correctamente. Valor detectado: $TLS_PRIVATE_KEY_FILE"
    exit 1
else
    echo "✅ Configuración correcta: tls-private-key-file está configurado como $TLS_PRIVATE_KEY_FILE"
fi

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: La configuración de --tls-cert-file y --tls-private-key-file es correcta."
exit 0
