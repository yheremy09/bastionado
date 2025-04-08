#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que --peer-client-cert-auth esté configurado como true en OpenShift etcd"

# 1️⃣ Verificar el valor de --peer-client-cert-auth en todos los pods de etcd
for i in $(oc get pods -o name -n openshift-etcd)
do
  PEER_CLIENT_CERT_AUTH=$(oc exec -n openshift-etcd -c etcd $i -- \
  ps -o command= -C etcd | sed 's/.*\(--peer-client-cert-auth=[^ ]*\).*/\1/')
  
  # Verificar si el valor es correcto
  if [ "$PEER_CLIENT_CERT_AUTH" != "--peer-client-cert-auth=true" ]; then
    echo "❌ Fallo: El --peer-client-cert-auth no está configurado correctamente en el pod $i. Valor detectado: $PEER_CLIENT_CERT_AUTH"
    exit 1
  else
    echo "✅ --peer-client-cert-auth está configurado correctamente en el pod $i: $PEER_CLIENT_CERT_AUTH"
  fi
done

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: El parámetro --peer-client-cert-auth está configurado correctamente en todos los pods de etcd."
exit 0
