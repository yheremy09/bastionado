# Echo mensaje inicial
echo "Checking OpenShift API Server configurations (4.6 and above)"

# Verificar que 'kubelet-client-certificate' está definido
CERTIFICATE_PATH=$(oc get configmap config -n openshift-kube-apiserver -ojson | jq -r '.data["config.yaml"]' | jq '.apiServerArguments["kubelet-client-certificate"]')

if [ "$CERTIFICATE_PATH" == "null" ] || [ -z "$CERTIFICATE_PATH" ]; then
    echo "Fallo: kubelet-client-certificate no está definido en la configuración del API Server."
    exit 1
fi

# Verificar que 'kubelet-client-key' está definido
KEY_PATH=$(oc get configmap config -n openshift-kube-apiserver -ojson | jq -r '.data["config.yaml"]' | jq '.apiServerArguments["kubelet-client-key"]')

if [ "$KEY_PATH" == "null" ] || [ -z "$KEY_PATH" ]; then
    echo "Fallo: kubelet-client-key no está definido en la configuración del API Server."
    exit 1
fi

# Verificar que el secreto 'serving-cert' existe en openshift-apiserver
SECRET_EXISTS=$(oc -n openshift-apiserver get secret serving-cert --ignore-not-found)

if [ -z "$SECRET_EXISTS" ]; then
    echo "Fallo: El secreto 'serving-cert' no existe en el namespace openshift-apiserver."
    exit 1
fi

# Si todas las verificaciones pasaron, mostrar éxito
echo "Éxito: Todas las configuraciones del API Server están correctas."
exit 0
