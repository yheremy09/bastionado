#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que --auto-tls no esté habilitado en los miembros de etcd"

# 1️⃣ Verificar si --auto-tls está habilitado en todos los pods de etcd
for i in $(oc get pods -o name -n openshift-etcd)
do
  AUTO_TLS=$(oc exec -n openshift-etcd -c etcd $i -- \
  ps -o command= -C etcd | grep -- '--auto-tls=true 2>&1>/dev/null' ; echo $?)

  # Verificar si el valor es correcto (no debería ser 1)
  if [ "$AUTO_TLS" -eq 0 ]; then
    echo "❌ Fallo: --auto-tls está habilitado en el pod $i. El valor debería ser false."
    exit 1
  else
    echo "✅ --auto-tls no está habilitado en el pod $i."
  fi
done

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: --auto-tls no está habilitado en ningún miembro de etcd."
exit 0
