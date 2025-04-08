# Ejecutar el comando y obtener la salida de namespaces
RESULT=$(oc get scc -o json | jq '.items[] | select(.allowHostIPC==false) | .metadata.name')
# Verificar si se obtuvo algún resultado
if [[ -n "$RESULT" ]]; then
    echo "Éxito en 5.2.3"
    exit 0
else
    echo "Fallo en 5.2.3"
    exit 1
fi
