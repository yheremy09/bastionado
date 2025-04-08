#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que la autenticación mediante certificados de cliente no esté habilitada para usuarios"

# 1️⃣ Verificar que la autenticación esté habilitada
echo "🔎 Verificando que la autenticación esté habilitada..."
AUTH_ENABLED=$(oc describe authentication)

if [[ ! "$AUTH_ENABLED" =~ "Authentication" ]]; then
    echo "❌ Fallo: La autenticación no está habilitada."
    exit 1
else
    echo "✅ Autenticación habilitada correctamente."
fi

# 2️⃣ Verificar que al menos un proveedor de identidad esté configurado
echo "🔎 Verificando que un proveedor de identidad esté configurado..."
IDP_CONFIGURED=$(oc get oauth -o json | jq '.items[].spec.identityProviders')

if [[ "$IDP_CONFIGURED" == "null" ]]; then
    echo "❌ Fallo: No se ha configurado un proveedor de identidad."
    exit 1
else
    echo "✅ Proveedor de identidad configurado correctamente."
fi

# 3️⃣ Verificar que el usuario kubeadmin no exista
echo "🔎 Verificando que el usuario kubeadmin no exista..."
KUBEADMIN_SECRET=$(oc get secrets kubeadmin -n kube-system)

if [[ "$KUBEADMIN_SECRET" != "No resources found" ]]; then
    echo "❌ Fallo: El secreto kubeadmin existe, debe ser eliminado."
    exit 1
else
    echo "✅ El secreto kubeadmin ha sido eliminado correctamente."
fi

# 4️⃣ Verificar que un usuario con el rol cluster-admin exista
echo "🔎 Verificando que al menos un usuario con rol cluster-admin exista..."
CLUSTER_ADMIN_USER=$(oc get clusterrolebindings -o='custom-columns=NAME:.metadata.name,ROLE:.roleRef.name,SUBJECT:.subjects[*].kind' | grep cluster-admin | grep User)

if [[ -z "$CLUSTER_ADMIN_USER" ]]; then
    echo "❌ Fallo: No hay usuarios con el rol cluster-admin."
    exit 1
else
    echo "✅ Usuario con rol cluster-admin encontrado."
fi

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: La autenticación con certificados de cliente para usuarios está deshabilitada correctamente."
exit 0
