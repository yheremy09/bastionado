# Echo mensaje inicial
echo "check kubeconfig file permissions for scheduler"

# Itera sobre los pods del namespace openshift-kube-scheduler con la etiqueta app=openshift-kube-scheduler
for i in $(oc get pods -n openshift-kube-scheduler -l app=openshift-kube-scheduler -o name)
do
    # Ejecuta el comando exec para obtener los permisos del archivo /etc/kubernetes/static-pod-resources/configmaps/scheduler-kubeconfig/kubeconfig
    PERMISSIONS=$(oc exec -n openshift-kube-scheduler $i -- stat -c %a /etc/kubernetes/static-pod-resources/configmaps/scheduler-kubeconfig/kubeconfig)

    # Verifica si los permisos son 600
    if [ "$PERMISSIONS" != "600" ]; then
        # Si los permisos no son 600, muestra un mensaje de fallo y termina con exit 1
        echo "Fallo en los permisos del archivo en el pod: $i. Permisos actuales: $PERMISSIONS"
        exit 1
    fi
done

# Si todos los pods tienen los permisos correctos, muestra un mensaje de éxito
echo "Éxito en los permisos del archivo kubeconfig en scheduler"
exit 0
