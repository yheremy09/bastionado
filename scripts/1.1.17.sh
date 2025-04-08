# Echo mensaje inicial
echo "check kubeconfig file permissions for controller-manager"

# Itera sobre los pods del namespace openshift-kube-controller-manager con la etiqueta app=kube-controller-manager
for i in $(oc get pods -n openshift-kube-controller-manager -l app=kube-controller-manager -o name)
do
    # Ejecuta el comando exec para obtener los permisos del archivo /etc/kubernetes/static-pod-resources/configmaps/controller-manager-kubeconfig/kubeconfig
    PERMISSIONS=$(oc exec -n openshift-kube-controller-manager $i -- stat -c %a /etc/kubernetes/static-pod-resources/configmaps/controller-manager-kubeconfig/kubeconfig)

    # Verifica si los permisos son 600
    if [ "$PERMISSIONS" != "600" ]; then
        # Si los permisos no son 600, muestra un mensaje de fallo y termina con exit 1
        echo "Fallo en los permisos del archivo en el pod: $i. Permisos actuales: $PERMISSIONS"
        exit 1
    fi
done

# Si todos los pods tienen los permisos correctos, muestra un mensaje de éxito
echo "Éxito en los permisos del archivo kubeconfig para controller-manager"
exit 0
