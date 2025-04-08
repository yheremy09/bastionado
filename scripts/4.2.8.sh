#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que el parámetro --event-qps (kubeAPIQPS) esté configurado adecuadamente"

# 1️⃣ Verificar el parámetro --event-qps (kubeAPIQPS) en todos los nodos
for node in $(oc get nodes -o jsonpath='{.items[*].metadata.name}')
do
  EVENT_QPS=$(oc get --raw /api/v1/nodes/$node/proxy/configz | jq '.kubeletconfig.kubeAPIQPS')

  # Verificar si el valor es 0 (lo que indicaría una configuración incorrecta)
  if [ "$EVENT_QPS" == "0" ]; then
    echo "❌ Fallo: El parámetro --event-qps está configurado en 0 en el nodo $node. Esto puede causar un Denial-of-Service."
    exit 1
  else
    echo "✅ El parámetro --event-qps (kubeAPIQPS) está configurado correctamente en el nodo $node: $EVENT_QPS"
  fi
done

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: El parámetro --event-qps (kubeAPIQPS) está configurado adecuadamente en todos los nodos."
exit 0
