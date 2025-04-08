#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que --cert-file y --key-file estén configurados correctamente para etcd"

# 1️⃣ Verificar el valor de --cert-file en todos los pods de etcd
echo "🔎 Verificando --cert-file en los pods de etcd..."
for i in $(oc get pods -o name -n openshift-etcd)
do
  CERT_FILE=$(oc exec -n openshift-etcd -c etcd $i -- \
  ps -o command= -C etcd | sed 's/.*\(--cert-file=[^ ]*\).*/\1/')
  
  # Verificar si el valor es correcto
  if [ "$CERT_FILE" != "--cert-file=/etc/kubernetes/static-pod-certs/secrets/etcd-all-serving/etcd-serving-${ETCD_DNS_NAME}.crt" ]; then
    echo "❌ Fallo: El --cert-file no está configurado correctamente en el pod $i. Valor detectado: $CERT_FILE"
    exit 1
  else
    echo "✅ --cert-file está configurado correctamente en el pod $i: $CERT_FILE"
  fi
done

# 2️⃣ Verificar el valor de --key-file en todos los pods de etcd
echo "🔎 Verificando --key-file en los pods de etcd..."
for i in $(oc get pods -o name -n openshift-etcd)
do
  KEY_FILE=$(oc exec -n openshift-etcd -c etcd $i -- \
  ps -o command= -C etcd | sed 's/.*\(--key-file=[^ ]*\).*/\1/')
  
  # Verificar si el valor es correcto
  if [ "$KEY_FILE" != "--key-file=/etc/kubernetes/static-pod-certs/secrets/etcd-all-serving/etcd-serving-${ETCD_DNS_NAME}.key" ]; then
    echo "❌ Fallo: El --key-file no está configurado correctamente en el pod $i. Valor detectado: $KEY_FILE"
    exit 1
  else
    echo "✅ --key-file está configurado correctamente en el pod $i: $KEY_FILE"
  fi
done

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: Los parámetros --cert-file y --key-file están configurados correctamente en todos los pods de etcd."
exit 0
