#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que el parámetro --client-ca-file esté configurado correctamente en los nodos"

# 1️⃣ Verificar el parámetro --client-ca-file en todos los nodos
for node in $(oc get nodes -o jsonpath='{.items[*].metadata.name}')
do
  CLIENT_CA_FILE=$(oc get --raw /api/v1/nodes/$node/proxy/configz | jq '.kubeletconfig.authentication.x509.clientCAFile')
  
  # Verificar si el valor es /etc/kubernetes/kubelet-ca.crt
  if [ "$CLIENT_CA_FILE" != "/etc/kubernetes/kubelet-ca.crt" ]; then
    echo "❌ Fallo: El archivo clientCAFile en el nodo $node no está configurado correctamente. Valor detectado: $CLIENT_CA_FILE"
    exit 1
  else
    echo "✅ El archivo clientCAFile está configurado correctamente en el nodo $node: $CLIENT_CA_FILE"
  fi
done

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: El parámetro --client-ca-file está configurado correctamente en todos los nodos."
exit 0
