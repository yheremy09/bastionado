#!/bin/bash

# Echo mensaje inicial
echo "Checking Kubernetes API Server secure port configurations"

# 1️⃣ Verificar que el bindAddress esté configurado en 0.0.0.0:6443
BIND_ADDRESS=$(oc get kubeapiservers.operator.openshift.io cluster -o json | jq -r '.spec.observedConfig.servingInfo.bindAddress')

if [ "$BIND_ADDRESS" != "0.0.0.0:6443" ]; then
    echo "Fallo: El bindAddress no está configurado en 0.0.0.0:6443. Valor detectado: $BIND_ADDRESS"
    exit 1
fi

# 2️⃣ Verificar que el API Server expone el puerto 6443
KUBE_API_PORT=$(oc get pods -n openshift-kube-apiserver -l app=openshift-kube-apiserver -o jsonpath='{.items[*].spec.containers[?(@.name=="kube-apiserver")].ports[*].containerPort}')

if [ "$KUBE_API_PORT" != "6443" ]; then
    echo "Fallo: El API Server de Kubernetes no está exponiendo el puerto 6443. Puerto detectado: $KUBE_API_PORT"
    exit 1
fi

# Si todas las verificaciones pasaron, mostrar éxito
echo "Éxito: La configuración del API Server es segura y cumple con los requisitos."
exit 0
