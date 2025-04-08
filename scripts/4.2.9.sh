#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando la configuración de los certificados TLS del Kubelet"

# 1️⃣ Verificar la ruta del archivo de certificado del cliente Kubelet
CERT_FILE=$(oc get configmap config -n openshift-kube-apiserver -o json | jq -r '.data["config.yaml"]' | jq '.apiServerArguments."kubelet-client-certificate"')

if [ "$CERT_FILE" != "/etc/kubernetes/static-pod-certs/secrets/kubelet-client/tls.crt" ]; then
  echo "❌ Fallo: El archivo de certificado del cliente Kubelet no está configurado correctamente. Valor detectado: $CERT_FILE"
  exit 1
else
  echo "✅ El archivo de certificado del cliente Kubelet está configurado correctamente: $CERT_FILE"
fi

# 2️⃣ Verificar la ruta de la clave privada del cliente Kubelet
KEY_FILE=$(oc get configmap config -n openshift-kube-apiserver -o json | jq -r '.data["config.yaml"]' | jq '.apiServerArguments."kubelet-client-key"')

if [ "$KEY_FILE" != "/etc/kubernetes/static-pod-certs/secrets/kubelet-client/tls.key" ]; then
  echo "❌ Fallo: El archivo de clave privada del cliente Kubelet no está configurado correctamente. Valor detectado: $KEY_FILE"
  exit 1
else
  echo "✅ El archivo de clave privada del cliente Kubelet está configurado correctamente: $KEY_FILE"
fi

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: Los parámetros TLS del Kubelet están configurados correctamente en todos los nodos."
exit 0
