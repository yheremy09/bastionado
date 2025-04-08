#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando la configuración de Image Provenance"

# 1️⃣ Verificar la configuración de registrySources
REGISTRY_SOURCES=$(oc get image.config.openshift.io/cluster -o json | jq .spec.registrySources)

if [ -z "$REGISTRY_SOURCES" ]; then
  echo "❌ Fallo: No se configuraron fuentes de registro de imágenes (registrySources)."
  exit 1
else
  echo "✅ Se configuraron las fuentes de registro de imágenes: $REGISTRY_SOURCES"
fi

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: Image Provenance está configurado correctamente."
exit 0
