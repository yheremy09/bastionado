#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que todos los namespaces tengan Network Policies definidas"

# 1️⃣ Verificar que cada namespace tenga al menos una Network Policy
for namespace in $(oc get namespaces -o jsonpath='{.items[*].metadata.name}')
do
  POLICY_COUNT=$(oc -n $namespace get networkpolicy --no-headers | wc -l)
  
  if [ "$POLICY_COUNT" -eq 0 ]; then
    echo "❌ Fallo: El namespace $namespace no tiene Network Policies definidas."
    exit 1
  else
    echo "✅ El namespace $namespace tiene Network Policies definidas."
  fi
done

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: Todos los namespaces tienen Network Policies definidas."
exit 0
