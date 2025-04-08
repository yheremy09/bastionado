# Echo mensaje inicial
echo "Checking ownership of static-pod-certs and static-pod-resources"

# Itera sobre los pods del namespace openshift-kube-apiserver con la etiqueta app=openshift-kube-apiserver
for i in $(oc -n openshift-kube-apiserver get pod -l app=openshift-kube-apiserver -o jsonpath='{.items[*].metadata.name}')
do 
    echo "Checking pod: $i"

    # Verificación en static-pod-certs (directorios)
    for dir in $(oc exec -n openshift-kube-apiserver $i -c kube-apiserver -- \
        find /etc/kubernetes/static-pod-certs -type d -wholename '*/secrets*')
    do
        OWNER=$(oc exec -n openshift-kube-apiserver $i -c kube-apiserver -- stat -c %U:%G "$dir")
        if [ "$OWNER" != "root:root" ]; then
            echo "Fallo en la propiedad del directorio $dir en el pod: $i. Propiedad actual: $OWNER"
            exit 1
        fi
    done

    # Verificación en static-pod-certs (archivos)
    for file in $(oc exec -n openshift-kube-apiserver $i -c kube-apiserver -- \
        find /etc/kubernetes/static-pod-certs -type f -wholename '*/secrets*')
    do
        OWNER=$(oc exec -n openshift-kube-apiserver $i -c kube-apiserver -- stat -c %U:%G "$file")
        if [ "$OWNER" != "root:root" ]; then
            echo "Fallo en la propiedad del archivo $file en el pod: $i. Propiedad actual: $OWNER"
            exit 1
        fi
    done

    # Verificación en static-pod-resources (directorios)
    for dir in $(oc exec -n openshift-kube-apiserver $i -c kube-apiserver -- \
        find /etc/kubernetes/static-pod-resources -type d -wholename '*/secrets*')
    do
        OWNER=$(oc exec -n openshift-kube-apiserver $i -c kube-apiserver -- stat -c %U:%G "$dir")
        if [ "$OWNER" != "root:root" ]; then
            echo "Fallo en la propiedad del directorio $dir en el pod: $i. Propiedad actual: $OWNER"
            exit 1
        fi
    done

    # Verificación en static-pod-resources (archivos)
    for file in $(oc exec -n openshift-kube-apiserver $i -c kube-apiserver -- \
        find /etc/kubernetes/static-pod-resources -type f -wholename '*/secrets*')
    do
        OWNER=$(oc exec -n openshift-kube-apiserver $i -c kube-apiserver -- stat -c %U:%G "$file")
        if [ "$OWNER" != "root:root" ]; then
            echo "Fallo en la propiedad del archivo $file en el pod: $i. Propiedad actual: $OWNER"
            exit 1
        fi
    done

done

# Si todas las verificaciones pasaron, muestra éxito
echo "Éxito en la verificación de propiedad en static-pod-certs y static-pod-resources"
exit 0
