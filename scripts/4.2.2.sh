#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que la autenticación anónima esté deshabilitada en el Kubelet"

# 1️⃣ Verificar la configuración de autenticación anónima en todos los nodos
for node in $(oc get nodes -o jsonpath='{.items[*].metadata.name}')
do
  ANON_AUTH=$(oc get --raw /api/v1/nodes/$node/proxy/configz | jq '.kubeletconfig.authentication.anonymous.enabled')
  
  # Verificar si la autenticación anónima está deshabilitada
  if [ "$ANON_AUTH" != "false" ]; then
    echo "❌ Fallo: La autenticación anónima está habilitada en el nodo $node. Valor detectado: $ANON_AUTH"
    exit 1
  else
    echo "✅ La autenticación anónima está deshabilitada correctamente en el nodo $node."
  fi
done

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: La autenticación anónima está deshabilitada en todos los nodos."
exit 0
