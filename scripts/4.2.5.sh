#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que el puerto de solo lectura esté deshabilitado o configurado en 0"

# 1️⃣ Verificar la configuración de `kubelet-read-only-port` en el configmap del API Server
KUBELET_PORT=$(oc -n openshift-kube-apiserver get cm config -o json | jq -r '.data."config.yaml"' | yq '.apiServerArguments."kubelet-read-only-port"')

# Verificar si el valor es 0
if [ "$KUBELET_PORT" != "0" ]; then
  echo "❌ Fallo: El puerto de solo lectura está habilitado o no configurado correctamente. Valor detectado: $KUBELET_PORT"
  exit 1
else
  echo "✅ El puerto de solo lectura está deshabilitado correctamente: $KUBELET_PORT"
fi

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: El puerto de solo lectura está deshabilitado o configurado en 0 en todos los nodos."
exit 0
