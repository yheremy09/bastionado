#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando la configuración de SCC para contenedores root"

# 1️⃣ Verificar los SCCs que restringen el uso de root
RESTRICTED_SCCS=$(oc get scc -A -o json | jq '.items[] | select(.runAsUser["type"] == "MustRunAsNonRoot") | .metadata.name')

if [ -z "$RESTRICTED_SCCS" ]; then
  echo "❌ Fallo: No se encontraron SCCs que restrinjan el uso de root."
  exit 1
else
  echo "✅ Se encontraron SCCs que restringen el uso de root: $RESTRICTED_SCCS"
fi

# 2️⃣ Verificar que el rango de UID no contenga 0
for i in $(oc get scc --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
do
  UID_RANGE=$(oc describe scc $i | grep "\sUID")
  
  if echo "$UID_RANGE" | grep -q "0"; then
    echo "❌ Fallo: El rango de UID en el SCC $i contiene el UID 0, lo que permite contenedores root."
    exit 1
  else
    echo "✅ El rango de UID en el SCC $i no permite contenedores root."
  fi
done

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: La configuración de SCC para contenedores root está correcta."
exit 0
