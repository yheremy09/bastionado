#!/bin/bash

# Echo mensaje inicial
echo "Checking Kubernetes API Server port"

# Obtener el puerto en el que está escuchando el API Server de Kubernetes
KUBE_API_PORT=$(oc -n openshift-kube-apiserver get endpoints -o jsonpath='{.items[*].subsets[*].ports[*].port}')

# Verificar que el puerto sea 6443
if [ "$KUBE_API_PORT" != "6443" ]; then
    echo "Fallo: El API Server de Kubernetes no está escuchando en el puerto 6443. Puerto detectado: $KUBE_API_PORT"
    exit 1
fi

# Si la verificación es exitosa
echo "Éxito: El API Server de Kubernetes está correctamente configurado en el puerto 6443."
exit 0
