# Ejecutar el comando y obtener la salida de namespaces
RESULT1=$(oc get scc -A -o json | jq -r '.items[] | select(.allowedCapabilities==null) | .metadata.name')
RESULT2=$(oc get scc -A -o json | jq -r '.items[] | select(.defaultAddCapabilities==null) | .metadata.name')

# Verificar si se obtuvo algún resultado
if [[ -n "$RESULT1" && -n "$RESULT2" ]]; then
    echo "Éxito en 5.2.8: Todas las SCC tienen configurados 'allowedCapabilities' y 'defaultAddCapabilities' como null."
    exit 0
else
    echo "Fallo en 5.2.8: Al menos una SCC tiene capacidades adicionales permitidas."
    exit 1
fi
