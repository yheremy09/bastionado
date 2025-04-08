#!/bin/bash

# Obtener la lista de admission controllers habilitados
ADMISSION_PLUGINS=$(oc -n openshift-kube-apiserver get configmap config -o json 2>/dev/null | jq -r '.data."config.yaml"' | jq -r '.apiServerArguments."enable-admission-plugins"[]' 2>/dev/null)

# Verificar si NamespaceLifecycle está presente
if [[ ! "$ADMISSION_PLUGINS" =~ "NamespaceLifecycle" ]]; then
    echo "Fallo en 1.2.13 - No se detectó NamespaceLifecycle en enable-admission-plugins"
    exit 1
fi

# Si la verificación pasó
echo "Éxito en 1.2.13"
exit 0
