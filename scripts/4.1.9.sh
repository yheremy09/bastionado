#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando los permisos del archivo de configuración de kubelet"

# 1️⃣ Verificar los permisos del archivo de configuración kubelet en nodos de OpenShift 4.13 y versiones posteriores
for node in $(oc get nodes -o jsonpath='{.items[*].metadata.name}')
do
  if oc get node $node -o jsonpath='{.status.nodeInfo.kubeletVersion}' | grep -q "v4.13"; then
    PERMISSIONS=$(oc debug node/${node} -- chroot /host stat -c %a /var/data/kubelet/config.json)
  else
    PERMISSIONS=$(oc debug node/${node} -- chroot /host stat -c %a /var/lib/kubelet/config.json)
  fi
  
  # Verificar si los permisos son 600 o más restrictivos
  if [ "$PERMISSIONS" != "600" ] && [ "$PERMISSIONS" != "640" ]; then
    echo "❌ Fallo: Los permisos del archivo kubelet config.json en el nodo $node son $PERMISSIONS. Deben ser 600 o más restrictivos."
    exit 1
  else
    echo "✅ Permisos del archivo kubelet config.json en el nodo $node son correctos: $PERMISSIONS"
  fi
done

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: Los permisos del archivo de configuración de kubelet son correctos en todos los nodos."
exit 0
