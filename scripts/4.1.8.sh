#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando la propiedad del archivo kubelet-ca.crt"

# 1️⃣ Verificar la propiedad del archivo kubelet-ca.crt en todos los nodos
for node in $(oc get nodes -o jsonpath='{.items[*].metadata.name}')
do
  OWNER_GROUP=$(oc debug node/${node} -- chroot /host stat -c %U:%G /etc/kubernetes/kubelet-ca.crt)
  
  # Verificar si la propiedad es root:root
  if [ "$OWNER_GROUP" != "root:root" ]; then
    echo "❌ Fallo: La propiedad del archivo kubelet-ca.crt en el nodo $node es $OWNER_GROUP. Debe ser root:root."
    exit 1
  else
    echo "✅ La propiedad del archivo kubelet-ca.crt en el nodo $node es correcta: $OWNER_GROUP"
  fi
done

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: La propiedad del archivo kubelet-ca.crt es root:root en todos los nodos."
exit 0
