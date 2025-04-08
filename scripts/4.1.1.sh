#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando los permisos del archivo de servicio kubelet"

# 1️⃣ Verificar los permisos del archivo kubelet en todos los nodos
for node in $(oc get nodes -o jsonpath='{.items[*].metadata.name}')
do
  PERMISSIONS=$(oc debug node/${node} -- chroot /host stat -c %a /etc/systemd/system/kubelet.service)
  
  # Verificar si los permisos son 644 o más restrictivos
  if [ "$PERMISSIONS" != "644" ] && [ "$PERMISSIONS" != "600" ]; then
    echo "❌ Fallo: Los permisos del archivo kubelet en el nodo $node son $PERMISSIONS. Deben ser 644 o más restrictivos."
    exit 1
  else
    echo "✅ Permisos del archivo kubelet en el nodo $node son correctos: $PERMISSIONS"
  fi
done

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: Los permisos del archivo kubelet son correctos en todos los nodos."
exit 0
