#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que el parámetro --make-iptables-util-chains esté configurado en true"

# 1️⃣ Verificar el parámetro --make-iptables-util-chains en todos los nodos
for node in $(oc get nodes -o jsonpath='{.items[*].metadata.name}')
do
  IPTABLES_CONFIG=$(oc get --raw /api/v1/nodes/$node/proxy/configz | jq '.kubeletconfig.makeIPTablesUtilChains')
  
  # Verificar si el valor es true
  if [ "$IPTABLES_CONFIG" != "true" ]; then
    echo "❌ Fallo: El parámetro makeIPTablesUtilChains está configurado en $IPTABLES_CONFIG en el nodo $node. Debe ser true."
    exit 1
  else
    echo "✅ El parámetro makeIPTablesUtilChains está configurado correctamente en el nodo $node: $IPTABLES_CONFIG"
  fi
done

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: El parámetro --make-iptables-util-chains está configurado correctamente en todos los nodos."
exit 0
