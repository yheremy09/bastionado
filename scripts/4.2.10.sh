#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que la rotación de certificados del Kubelet esté habilitada"

# 1️⃣ Verificar la rotación de certificados en todos los nodos
for node in $(oc get nodes -o jsonpath='{.items[*].metadata.name}')
do
  ROTATE_CERTS=$(oc get --raw /api/v1/nodes/$node/proxy/configz | jq '.kubeletconfig.rotateCertificates')
  
  # Verificar si el valor es true
  if [ "$ROTATE_CERTS" != "true" ]; then
    echo "❌ Fallo: La rotación de certificados no está habilitada en el nodo $node. Valor detectado: $ROTATE_CERTS"
    exit 1
  else
    echo "✅ La rotación de certificados está habilitada correctamente en el nodo $node: $ROTATE_CERTS"
  fi
done

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: La rotación de certificados del Kubelet está habilitada correctamente en todos los nodos."
exit 0
