# Echo mensaje inicial
echo "check etcd member directory permissions"

# Itera sobre los pods del namespace openshift-etcd con la etiqueta app=etcd
for i in $(oc get pods -n openshift-etcd -l app=etcd -o name); do
    # Ejecuta el comando exec para obtener los permisos del directorio /var/lib/etcd/member
    PERMISSIONS=$(oc exec -n openshift-etcd -c etcd $i -- stat -c %a /var/lib/etcd/member)

    # Verifica si los permisos son 700
    if [ "$PERMISSIONS" != "700" ]; then
        # Si los permisos no son 700, muestra un mensaje de fallo y termina con exit 1
        echo "Fallo en los permisos del directorio /var/lib/etcd/member en el pod: $i. Permisos actuales: $PERMISSIONS"
        exit 1
    fi
done

# Si todos los pods tienen los permisos correctos, muestra un mensaje de éxito
echo "Éxito en los permisos del directorio /var/lib/etcd/member"
exit 0
