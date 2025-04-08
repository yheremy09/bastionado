# Echo mensaje inicial
echo "Checking authorization-mode in OpenShift API Server"

# Extraer los valores de authorization-mode desde la ConfigMap
AUTH_MODE=$(oc get configmap config -n openshift-kube-apiserver -ojson | jq -r '.data["config.yaml"]' | jq -c '.apiServerArguments."authorization-mode"')

# Definir los valores esperados
EXPECTED_VALUES=("Scope" "SystemMasters" "RBAC" "Node")

# Comprobar si authorization-mode está presente
if [ "$AUTH_MODE" == "null" ] || [ -z "$AUTH_MODE" ]; then
    echo "Fallo: authorization-mode no está definido en la configuración del API Server."
    exit 1
fi

# Comprobar si authorization-mode contiene los valores esperados
MISSING_VALUES=()
for value in "${EXPECTED_VALUES[@]}"; do
    if ! echo "$AUTH_MODE" | grep -q "$value"; then
        MISSING_VALUES+=("$value")
    fi
done

if [ ${#MISSING_VALUES[@]} -ne 0 ]; then
    echo "Fallo: authorization-mode no contiene los valores esperados. Faltan: ${MISSING_VALUES[*]}"
    exit 1
fi

# Si la verificación es exitosa
echo "Éxito: authorization-mode está correctamente definido con los valores esperados."
exit 0

