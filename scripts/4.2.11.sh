#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que la rotación del certificado del servidor Kubelet esté habilitada"

# 1️⃣ Verificar si RotateKubeletServerCertificate está habilitado en todos los nodos
for node in $(oc get nodes -o jsonpath='{.items[*].metadata.name}')
do
  ROTATE_SERVER_CERTS=$(oc get --raw /api/v1/nodes/$node/proxy/configz | jq '.kubeletconfig.featureGates.RotateKubeletServerCertificate')

  # Verificar si el valor es true
  if [ "$ROTATE_SERVER_CERTS" != "true" ]; then
    echo "❌ Fallo: La rotación del certificado del servidor Kubelet no está habilitada en el nodo $node. Valor detectado: $ROTATE_SERVER_CERTS"
    exit 1
  else
    echo "✅ La rotación del certificado del servidor Kubelet está habilitada correctamente en el nodo $node."
  fi
done

# 2️⃣ Verificar si la rotación de certificados está habilitada correctamente
for node in $(oc get nodes -o jsonpath='{.items[*].metadata.name}')
do
  ROTATE_CERTS=$(oc get --raw /api/v1/nodes/$node/proxy/configz | jq '.kubeletconfig.rotateCertificates')

  # Verificar si el valor es true
  if [ "$ROTATE_CERTS" != "true" ]; then
    echo "❌ Fallo: La rotación de certificados no está habilitada correctamente en el nodo $node. Valor detectado: $ROTATE_CERTS"
    exit 1
  else
    echo "✅ La rotación de certificados está habilitada correctamente en el nodo $node."
  fi
done

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: La rotación de certificados del servidor Kubelet está habilitada correctamente en todos los nodos."
exit 0
