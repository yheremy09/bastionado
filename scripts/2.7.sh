#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que los parámetros --trusted-ca-file y --peer-trusted-ca-file estén configurados correctamente para etcd"

# 1️⃣ Verificar el valor de --trusted-ca-file en todos los pods de etcd
echo "🔎 Verificando --trusted-ca-file en los pods de etcd..."
for i in $(oc get pods -o name -n openshift-etcd)
do
  TRUSTED_CA_FILE=$(oc exec -n openshift-etcd -c etcd $i -- \
  ps -o command= -C etcd | sed 's/.*\(--trusted-ca-file=[^ ]*\).*/\1/')
  
  # Verificar si el valor es correcto
  if [ "$TRUSTED_CA_FILE" != "--trusted-ca-file=/etc/kubernetes/static-pod-certs/configmaps/etcd-serving-ca/ca-bundle.crt" ]; then
    echo "❌ Fallo: El --trusted-ca-file no está configurado correctamente en el pod $i. Valor detectado: $TRUSTED_CA_FILE"
    exit 1
  else
    echo "✅ --trusted-ca-file está configurado correctamente en el pod $i: $TRUSTED_CA_FILE"
  fi
done

# 2️⃣ Verificar el valor de --peer-trusted-ca-file en todos los pods de etcd
echo "🔎 Verificando --peer-trusted-ca-file en los pods de etcd..."
for i in $(oc get pods -o name -n openshift-etcd)
do
  PEER_TRUSTED_CA_FILE=$(oc exec -n openshift-etcd -c etcd $i -- \
  ps -o command= -C etcd | sed 's/.*\(--peer-trusted-ca-file=[^ ]*\).*/\1/')
  
  # Verificar si el valor es correcto
  if [ "$PEER_TRUSTED_CA_FILE" != "--peer-trusted-ca-file=/etc/kubernetes/static-pod-certs/configmaps/etcd-peer-client-ca/ca-bundle.crt" ]; then
    echo "❌ Fallo: El --peer-trusted-ca-file no está configurado correctamente en el pod $i. Valor detectado: $PEER_TRUSTED_CA_FILE"
    exit 1
  else
    echo "✅ --peer-trusted-ca-file está configurado correctamente en el pod $i: $PEER_TRUSTED_CA_FILE"
  fi
done

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: Los parámetros --trusted-ca-file y --peer-trusted-ca-file están configurados correctamente en todos los pods de etcd."
exit 0
