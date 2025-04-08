#!/bin/bash

# Array para almacenar usuarios y grupos con acceso al rol cluster-admin
users_and_groups_with_cluster_admin=()

# Obtener la lista de usuarios y grupos con el rol cluster-admin
echo "Obteniendo usuarios y grupos con el rol cluster-admin..."
oc get clusterrolebindings -o=custom-columns=NAME:.metadata.name,ROLE:.roleRef.name,SUBJECT:.subjects[*].kind | grep cluster-admin | while read line; do
    # Extraer el nombre de los usuarios y grupos
    users=$(echo $line | awk '{print $3}')
    
    # Agregar los usuarios/grupos al array (sin duplicados)
    for user in $users; do
        if [[ ! " ${users_and_groups_with_cluster_admin[@]} " =~ " ${user} " ]]; then
            users_and_groups_with_cluster_admin+=("$user")
        fi
    done
done

# Imprimir los usuarios y grupos con cluster-admin
echo "Usuarios y grupos con el rol cluster-admin:"
echo "${users_and_groups_with_cluster_admin[@]}"

# Verificar si la cuenta kubeadmin existe
echo "Verificando si la cuenta kubeadmin existe..."
kubeadmin_exists=$(oc get secrets kubeadmin -n kube-system --ignore-not-found)

if [[ -z "$kubeadmin_exists" ]]; then
    echo "La cuenta kubeadmin NO existe."
    exit 2
else
    echo "La cuenta kubeadmin SÍ existe. Fallo en 5.1.1"
    exit 1
fi
