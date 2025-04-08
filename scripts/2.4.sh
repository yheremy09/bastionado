#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que --peer-cert-file y --peer-key-file estén configurados correctamente para etcd"

# 1️⃣ Verificar el valor de --peer-cert-file en todos los pods de etcd
echo "🔎 Verificando --peer-cert-file en los pods de etcd..."
for i in $(oc get pods -o name -n openshift-etcd)
do
  PEER_CERT_FILE=$(oc exec -n openshift-etcd -c etcd $i -- \
  ps -o command= -C etcd | sed 's/.*\(--peer-cert-file=[^ ]*\).*/\1/')
  
  # Verificar si el valor es correcto
  if [ "$PEER_CERT_FILE" != "--peer-cert-file=/etc/kubernetes/static-pod-certs/secrets/etcd-all-peer/etcd-peer-${ETCD_DNS_NAME}.crt" ]; then
    echo "❌ Fallo: El --peer-cert-file no está configurado correctamente en el pod $i. Valor detectado: $PEER_CERT_FILE"
    exit 1
  else
    echo "✅ --peer-cert-file está configurado correctamente en el pod $i: $PEER_CERT_FILE"
  fi
done

# 2️⃣ Verificar el valor de --peer-key-file en todos los pods de etcd
echo "🔎 Verificando --peer-key-file en los pods de etcd..."
for i in $(oc get pods -o name -n openshift-etcd)
do
  PEER_KEY_FILE=$(oc exec -n openshift-etcd -c etcd $i -- \
  ps -o command= -C etcd | sed 's/.*\(--peer-key-file=[^ ]*\).*/\1/')
  
  # Verificar si el valor es correcto
  if [ "$PEER_KEY_FILE" != "--peer-key-file=/etc/kubernetes/static-pod-certs/secrets/etcd-all-peer/etcd-peer-${ETCD_DNS_NAME}.key" ]; then
    echo "❌ Fallo: El --peer-key-file no está configurado correctamente en el pod $i. Valor detectado: $PEER_KEY_FILE"
    exit 1
  else
    echo "✅ --peer-key-file está configurado correctamente en el pod $i: $PEER_KEY_FILE"
  fi
done

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: Los parámetros --peer-cert-file y --peer-key-file están configurados correctamente en todos los pods de etcd."
exit 0
