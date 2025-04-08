#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que el perfil seccomp esté configurado adecuadamente en los pods"

# 1️⃣ Buscar pods sin perfil seccomp configurado
PODS_SIN_SECCOMP=$(oc get pods -A -o json | jq '.items[] | select( (.metadata.namespace | test("^kube*|^openshift*") | not) and .spec.securityContext.seccompProfile.type==null) | (.metadata.namespace + "/" + .metadata.name)')

if [ -z "$PODS_SIN_SECCOMP" ]; then
  echo "✅ Todos los pods tienen un perfil seccomp configurado correctamente."
else
  echo "❌ Fallo: Los siguientes pods no tienen un perfil seccomp configurado: $PODS_SIN_SECCOMP"
  exit 1
fi

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: Todos los pods tienen un perfil seccomp configurado correctamente."
exit 0
