# Echo mensaje inicial
echo "Checking enable-admission-plugins in OpenShift API Server"

# Extraer los valores de enable-admission-plugins desde la ConfigMap
ADMISSION_PLUGINS=$(oc -n openshift-kube-apiserver get configmap config -o json | jq -r '.data["config.yaml"]' | jq -c '.apiServerArguments."enable-admission-plugins"')

# Definir los valores esperados
EXPECTED_PLUGINS=("NamespaceLifecycle" "NodeRestriction" "LimitRanger" "ServiceAccount" "ResourceQuota")

# Comprobar si enable-admission-plugins está presente
if [ "$ADMISSION_PLUGINS" == "null" ] || [ -z "$ADMISSION_PLUGINS" ]; then
    echo "Fallo: enable-admission-plugins no está definido en la configuración del API Server."
    exit 1
fi

# Comprobar si enable-admission-plugins contiene los valores esperados
MISSING_PLUGINS=()
for plugin in "${EXPECTED_PLUGINS[@]}"; do
    if ! echo "$ADMISSION_PLUGINS" | grep -q "$plugin"; then
        MISSING_PLUGINS+=("$plugin")
    fi
done

if [ ${#MISSING_PLUGINS[@]} -ne 0 ]; then
    echo "Fallo: enable-admission-plugins no contiene los valores esperados. Faltan: ${MISSING_PLUGINS[*]}"
    exit 1
fi

# Si la verificación es exitosa
echo "Éxito: enable-admission-plugins está correctamente definido con los valores esperados."
exit 0

