#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que --client-cert-auth esté configurado como true en OpenShift etcd"

# 1️⃣ Verificar el valor de --client-cert-auth en todos los pods de etcd
for i in $(oc get pods -o name -n openshift-etcd)
do
  CLIENT_CERT_AUTH=$(oc exec -n openshift-etcd -c etcd $i -- \
  ps -o command= -C etcd | sed 's/.*\(--client-cert-auth=[^ ]*\).*/\1/')
  
  # Verificar si el valor es correcto
  if [ "$CLIENT_CERT_AUTH" != "--client-cert-auth=true" ]; then
    echo "❌ Fallo: El --client-cert-auth no está configurado correctamente en el pod $i. Valor detectado: $CLIENT_CERT_AUTH"
    exit 1
  else
    echo "✅ --client-cert-auth está configurado correctamente en el pod $i: $CLIENT_CERT_AUTH"
  fi
done

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: El parámetro --client-cert-auth está configurado correctamente en todos los pods de etcd."
exit 0
