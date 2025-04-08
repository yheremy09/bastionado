#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando la configuración de la recolección de basura (Garbage Collection)"

# 1️⃣ Verificar la configuración de recolección de basura en cada nodo
for node in $(oc get nodes -o jsonpath='{.items[*].metadata.name}')
do
  GC_CONFIG=$(oc get --raw /api/v1/nodes/$node/proxy/configz | jq '.kubeletconfig')

  # Verificar los valores de los umbrales de evacuación
  EVICTION_HARD=$(echo $GC_CONFIG | jq -r '.evictionHard')
  EVICTION_SOFT=$(echo $GC_CONFIG | jq -r '.evictionSoft')
  IMAGE_GC=$(echo $GC_CONFIG | jq -r '.imageGCHighThresholdPercent, .imageGCLowThresholdPercent')
  
  # Verificar si los umbrales son adecuados
  if [[ -z "$EVICTION_HARD" || -z "$EVICTION_SOFT" || -z "$IMAGE_GC" ]]; then
    echo "❌ Fallo: La configuración de la recolección de basura no está configurada adecuadamente en el nodo $node."
    exit 1
  else
    echo "✅ La configuración de la recolección de basura en el nodo $node está configurada adecuadamente."
  fi
done

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: La configuración de la recolección de basura está correcta en todos los nodos."
exit 0
