#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando la configuración de --etcd-certfile y --etcd-keyfile en OpenShift API Server"

# 1️⃣ Verificar el archivo de certificado etcd-certfile
ETCD_CERTFILE=$(oc get configmap config -n openshift-kube-apiserver -ojson | \
    jq -r '.data["config.yaml"]' | \
    jq -r '.apiServerArguments["etcd-certfile"]')

# Verificar si el archivo es correcto
if [ "$ETCD_CERTFILE" != "/etc/kubernetes/static-pod-resources/secrets/etcd-client/tls.crt" ]; then
    echo "❌ Fallo: etcd-certfile no está configurado correctamente. Valor detectado: $ETCD_CERTFILE"
    exit 1
else
    echo "✅ Configuración correcta: etcd-certfile está configurado como $ETCD_CERTFILE"
fi

# 2️⃣ Verificar el archivo de clave etcd-keyfile
ETCD_KEYFILE=$(oc get configmap config -n openshift-kube-apiserver -ojson | \
    jq -r '.data["config.yaml"]' | \
    jq -r '.apiServerArguments["etcd-keyfile"]')

# Verificar si el archivo es correcto
if [ "$ETCD_KEYFILE" != "/etc/kubernetes/static-pod-resources/secrets/etcd-client/tls.key" ]; then
    echo "❌ Fallo: etcd-keyfile no está configurado correctamente. Valor detectado: $ETCD_KEYFILE"
    exit 1
else
    echo "✅ Configuración correcta: etcd-keyfile está configurado como $ETCD_KEYFILE"
fi

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: La configuración de --etcd-certfile y --etcd-keyfile es correcta."
exit 0
