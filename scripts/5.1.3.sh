#!/bin/bash

# Array para almacenar los ClusterRoles con wildcards
clusterroles_with_wildcards=()

# Array para almacenar los Roles con wildcards
roles_with_wildcards=()

# Array para almacenar los usuarios que tienen esos ClusterRoles y Roles
users_with_wildcards=()

# Comprobar los ClusterRoles por uso de wildcards
echo "Comprobando ClusterRoles por uso de wildcards..."
oc get clusterroles -o name | while read clusterrole; do
    # Describir el ClusterRole y buscar wildcards en las reglas
    description=$(oc describe $clusterrole)
    
    # Verificar si hay wildcards en las reglas de recursos o verbos
    if echo "$description" | grep -q -A 10 "PolicyRule" | grep -q "\*"; then
        # Si se encuentra un wildcard, agregar el ClusterRole al array
        clusterroles_with_wildcards+=("$clusterrole")
        
        # Obtener los usuarios que pueden usar este ClusterRole con wildcards
        users=$(oc adm policy who-can use $clusterrole | grep 'user' | awk '{print $1}')
        
        # Agregar los usuarios a un array (sin duplicados)
        for user in $users; do
            if [[ ! " ${users_with_wildcards[@]} " =~ " ${user} " ]]; then
                users_with_wildcards+=("$user")
            fi
        done
    fi
done

# Imprimir los resultados
echo "ClusterRoles con wildcards:"
echo "${clusterroles_with_wildcards[@]}"

echo "Usuarios con permisos para usar esos ClusterRoles:"
echo "${users_with_wildcards[@]}"
exit 2
