#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando el uso de secretos como variables de entorno"

# 1️⃣ Verificar los objetos que usan secretos como variables de entorno
SECRETS_ENV_VARS=$(oc get all -o jsonpath='{range .items[?(@..secretKeyRef)]} {.kind} {.metadata.name} {"\n"}{end}' -A)

if [ -z "$SECRETS_ENV_VARS" ]; then
  echo "✅ No se encontraron secretos definidos como variables de entorno."
else
  echo "❌ Fallo: Se encontraron objetos utilizando secretos como variables de entorno: $SECRETS_ENV_VARS"
  exit 1
fi

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: Todos los secretos están siendo utilizados de manera segura (como archivos)."
exit 0
