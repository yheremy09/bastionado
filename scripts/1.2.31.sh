#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que el almacenamiento de etcd esté cifrado"

# Obtener el estado de la condición del Openshift API Server para verificar el cifrado del datastore
ETCD_ENCRYPTION_STATUS=$(oc get openshiftapiserver -o=jsonpath='{range .items[0].status.conditions[?(@.type=="Encrypted")]}{.reason}{"\n"}{.message}{"\n"}')

# Verificar si el estado indica que está cifrado
if [[ ! "$ETCD_ENCRYPTION_STATUS" =~ "Encrypted" ]]; then
    echo "❌ Fallo: El almacenamiento de etcd no está cifrado correctamente. Estado actual: $ETCD_ENCRYPTION_STATUS"
    exit 1
else
    echo "✅ El almacenamiento de etcd está cifrado correctamente. Estado: $ETCD_ENCRYPTION_STATUS"
fi

# Finalizar con éxito si todo está correcto
exit 0

