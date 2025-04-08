# Echo mensaje inicial
echo "check kubeconfig file ownership for scheduler"

# Itera sobre los pods del namespace openshift-kube-scheduler con la etiqueta app=openshift-kube-scheduler
for i in $(oc get pods -n openshift-kube-scheduler -l app=openshift-kube-scheduler -o name)
do
    # Ejecuta el comando exec para obtener la propiedad del archivo /etc/kubernetes/static-pod-resources/configmaps/scheduler-kubeconfig/kubeconfig (usuario:grupo)
    OWNER=$(oc exec -n openshift-kube-scheduler $i -- stat -c %U:%G /etc/kubernetes/static-pod-resources/configmaps/scheduler-kubeconfig/kubeconfig)

    # Verifica si la propiedad es root:root
    if [ "$OWNER" != "root:root" ]; then
        # Si la propiedad no es root:root, muestra un mensaje de fallo y termina con exit 1
        echo "Fallo en la propiedad del archivo en el pod: $i. Propiedad actual: $OWNER"
        exit 1
    fi
done

# Si todos los pods tienen la propiedad correcta, muestra un mensaje de éxito
echo "Éxito en la propiedad del archivo kubeconfig en scheduler"
exit 0
