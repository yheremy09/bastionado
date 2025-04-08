# Echo mensaje inicial
echo "Checking permissions of static-pod-certs certificate files"

# Itera sobre los pods del namespace openshift-kube-apiserver con la etiqueta app=openshift-kube-apiserver
for i in $(oc -n openshift-kube-apiserver get pod -l app=openshift-kube-apiserver -o jsonpath='{.items[*].metadata.name}')
do 
    echo "Checking pod: $i"

    # Buscar archivos .crt en /etc/kubernetes/static-pod-certs/secrets/
    for file in $(oc exec -n openshift-kube-apiserver $i -c kube-apiserver -- \
        find /etc/kubernetes/static-pod-certs -type f -wholename '*/secrets/*.crt')
    do
        PERMISSIONS=$(oc exec -n openshift-kube-apiserver $i -c kube-apiserver -- stat -c %a "$file")

        # Verifica si los permisos son 600 o más restrictivos (600, 400, 440, etc.)
        if [ "$PERMISSIONS" -gt "600" ]; then
            echo "Fallo en los permisos del archivo $file en el pod: $i. Permisos actuales: $PERMISSIONS"
            exit 1
        fi
    done
done

# Si todas las verificaciones pasaron, muestra éxito
echo "Éxito en la verificación de permisos de los archivos de certificados en static-pod-certs"
exit 0
