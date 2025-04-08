
# Ejecutar el comando y obtener la salida de namespaces
RESULT=$(oc get scc -A -o json | jq '.items[] | select(.requiredDropCapabilities[]?|any(. == "ALL"; .)) | .metadata.name')

# Verificar si se obtuvo algún resultado
if [[ -n "$RESULT" ]]; then
    echo "Éxito en 5.2.7"
    exit 0
else
    echo "Fallo en 5.2.7"
    exit 1
fi

