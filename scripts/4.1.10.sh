#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando la propiedad del archivo de configuración kubelet.conf o config.json"

# 1️⃣ Verificar la propiedad del archivo kubelet.conf/config.json en nodos de OpenShift 4.13 y versiones posteriores
for node in $(oc get nodes -o jsonpath='{.items[*].metadata.name}')
do
  if oc get node $node -o jsonpath='{.status.nodeInfo.kubeletVersion}' | grep -q "v4.13"; then
    OWNER_GROUP=$(oc debug node/${node} -- chroot /host stat -c %U:%G /var/data/kubelet/config.json)
  else
    OWNER_GROUP=$(oc debug node/${node} -- chroot /host stat -c %U:%G /var/lib/kubelet/config.json)
  fi
  
  # Verificar si la propiedad es root:root
  if [ "$OWNER_GROUP" != "root:root" ]; then
    echo "❌ Fallo: La propiedad del archivo kubelet.conf/config.json en el nodo $node es $OWNER_GROUP. Debe ser root:root."
    exit 1
  else
    echo "✅ La propiedad del archivo kubelet.conf/config.json en el nodo $node es correcta: $OWNER_GROUP"
  fi
done

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: La propiedad del archivo kubelet.conf/config.json es root:root en todos los nodos."
exit 0
