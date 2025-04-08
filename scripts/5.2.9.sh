#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando la configuración de SCC para eliminar todas las capacidades de los contenedores"

# 1️⃣ Verificar SCCs que eliminan todas las capacidades
RESTRICTED_SCCS=$(oc get scc -A -o json | jq '.items[] | select(.requiredDropCapabilities[]?|any(. == "ALL"; .)) | .metadata.name')

if [ -z "$RESTRICTED_SCCS" ]; then
  echo "❌ Fallo: No se encontraron SCCs que eliminen todas las capacidades."
  exit 1
else
  echo "✅ Se encontraron SCCs que eliminan todas las capacidades: $RESTRICTED_SCCS"
fi

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: La configuración de SCC para eliminar todas las capacidades está correcta."
exit 0
