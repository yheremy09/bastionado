#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando los permisos del archivo kubelet-ca.crt"

# 1️⃣ Verificar el archivo clientCAFile en todos los nodos
for node in $(oc get nodes -o jsonpath='{.items[*].metadata.name}')
do
  CLIENT_CA_FILE=$(oc get --raw /api/v1/nodes/$node/proxy/configz | jq '.kubeletconfig.authentication.x509.clientCAFile')

  # Verificar si el archivo clientCAFile está configurado correctamente
  if [ "$CLIENT_CA_FILE" != "/etc/kubernetes/kubelet-ca.crt" ]; then
    echo "❌ Fallo: El archivo de autoridad de certificación no está configurado correctamente en el nodo $node. Valor detectado: $CLIENT_CA_FILE"
    exit 1
  else
    echo "✅ El archivo de autoridad de certificación está configurado correctamente en el nodo $node."
  fi
done

# 2️⃣ Verificar los permisos del archivo kubelet-ca.crt en todos los nodos
for node in $(oc get nodes -o jsonpath='{.items[*].metadata.name}')
do
  PERMISSIONS=$(oc debug node/${node} -- chroot /host stat -c %a /etc/kubernetes/kubelet-ca.crt)
  
  # Verificar si los permisos son 644 o más restrictivos
  if [ "$PERMISSIONS" != "644" ] && [ "$PERMISSIONS" != "600" ]; then
    echo "❌ Fallo: Los permisos del archivo kubelet-ca.crt en el nodo $node son $PERMISSIONS. Deben ser 644 o más restrictivos."
    exit 1
  else
    echo "✅ Permisos del archivo kubelet-ca.crt en el nodo $node son correctos: $PERMISSIONS"
  fi
done

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: Los permisos del archivo kubelet-ca.crt son correctos en todos los nodos."
exit 0
