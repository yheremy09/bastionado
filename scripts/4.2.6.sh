#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que el parámetro --streaming-connection-idle-timeout no esté configurado en 0"

# 1️⃣ Verificar el parámetro --streaming-connection-idle-timeout en todos los nodos
for node in $(oc get nodes -o jsonpath='{.items[*].metadata.name}')
do
  IDLE_TIMEOUT=$(oc get --raw /api/v1/nodes/$node/proxy/configz | jq '.kubeletconfig.streamingConnectionIdleTimeout')
  
  # Verificar si el valor es 0
  if [ "$IDLE_TIMEOUT" == "0" ]; then
    echo "❌ Fallo: El tiempo de espera de la conexión de streaming está configurado a 0 en el nodo $node."
    exit 1
  else
    echo "✅ El tiempo de espera de la conexión de streaming está configurado correctamente en el nodo $node: $IDLE_TIMEOUT"
  fi
done

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: El parámetro --streaming-connection-idle-timeout no está configurado en 0 en todos los nodos."
exit 0
