# Echo mensaje inicial
echo "Checking kubelet-certificate-authority in OpenShift API Server (4.6 and above)"

# Verificar que 'kubelet-certificate-authority' está definido en la ConfigMap
CERT_AUTHORITY=$(oc get configmap config -n openshift-kube-apiserver -ojson | jq -r '.data["config.yaml"]' | jq '.apiServerArguments["kubelet-certificate-authority"]')

if [ "$CERT_AUTHORITY" == "null" ] || [ -z "$CERT_AUTHORITY" ]; then
    echo "Fallo: kubelet-certificate-authority no está definido en la configuración del API Server."
    exit 1
fi

# Si la verificación es exitosa
echo "Éxito: kubelet-certificate-authority está correctamente definido."
exit 0

