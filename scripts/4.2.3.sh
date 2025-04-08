#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que el parámetro --authorization-mode no esté configurado en AlwaysAllow"

# 1️⃣ Verificar el parámetro --authorization-mode en todos los nodos
for node in $(oc get nodes -o jsonpath='{.items[*].metadata.name}')
do
  AUTH_MODE=$(oc get --raw /api/v1/nodes/$node/proxy/configz | jq '.kubeletconfig.authorization.mode')
  
  # Verificar si el valor es AlwaysAllow
  if [ "$AUTH_MODE" == "AlwaysAllow" ]; then
    echo "❌ Fallo: El modo de autorización en el nodo $node está configurado como AlwaysAllow."
    exit 1
  else
    echo "✅ El modo de autorización en el nodo $node está configurado correctamente: $AUTH_MODE"
  fi
done

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: El modo de autorización no está configurado como AlwaysAllow en todos los nodos."
exit 0
