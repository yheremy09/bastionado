# Ejecutar el comando y obtener la salida de namespaces
RESULT=$(oc get scc -o json | jq '.items[] | select(.allowPrivilegedContainer==false) | .metadata.name')
# Verificar si se obtuvo algún resultado
if [[ -n "$RESULT" ]]; then
    echo "Éxito en 5.2.1"
    exit 0
else
    echo "Fallo en 5.2.1"
    exit 1
fi
