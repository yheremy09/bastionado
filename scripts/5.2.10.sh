#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando el acceso a SCCs privilegiados"

# 1️⃣ Verificar los SCCs con acceso privilegiado
SCC_PRIVILEGIADOS=$(oc get scc -ojson | jq '.items[]|select(.allowHostIPC or .allowHostPID or .allowHostPorts or .allowHostNetwork or .allowHostDirVolumePlugin or .allowPrivilegedContainer or .runAsUser.type != "MustRunAsRange")|.metadata.name,{"Group:":.groups},{"User":.users}')

if [ -z "$SCC_PRIVILEGIADOS" ]; then
  echo "❌ Fallo: No se encontraron SCCs con acceso privilegiado."
  exit 1
else
  echo "✅ Se encontraron SCCs con acceso privilegiado: $SCC_PRIVILEGIADOS"
fi

# 2️⃣ Verificar que solo los usuarios y grupos necesarios tengan acceso a los SCCs
# Para este paso, se recomienda revisar manualmente los usuarios y grupos devueltos por el comando anterior.

echo "📜 Revise los usuarios y grupos con acceso a SCCs privilegiados y asegúrese de que solo los necesarios tengan acceso."

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: La verificación de los SCCs privilegiados se completó correctamente."
exit 0
