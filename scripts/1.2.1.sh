#!/bin/bash

# Lista de nombres permitidos
ALLOWED_LIST=(
    "self-access-reviewers"
    "system:oauth-token-deleters"
    "system:openshift:public-info-viewer"
    "system:public-info-viewer"
    "system:scope-impersonation"
    "system:webhooks"
)

# Ejecutar el comando y obtener la salida
RESULT=$(oc get clusterrolebindings -o json | jq -r '.items[] | select(.subjects[]?.kind == "Group" and .subjects[]?.name == "system:unauthenticated") | .metadata.name' | uniq)

# Verificar si hay resultados no autorizados
for ITEM in $RESULT; do
    if [[ ! " ${ALLOWED_LIST[@]} " =~ " ${ITEM} " ]]; then
        echo "Fallo en 1.2.1"
        exit 1
    fi
done

echo "Éxito en 1.2.1"
exit 0
