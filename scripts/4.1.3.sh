#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando los permisos del archivo de configuración de kube-proxy"

# 1️⃣ Verificar los permisos del archivo kube-proxy en todos los pods de openshift-sdn
for i in $(oc get pods -n openshift-sdn -l app=sdn -o name)
do
  PERMISSIONS=$(oc exec -n openshift-sdn $i -- stat -Lc %a /config/kube-proxy-config.yaml)
  
  # Verificar si los permisos son 644 o más restrictivos
  if [ "$PERMISSIONS" != "644" ] && [ "$PERMISSIONS" != "600" ]; then
    echo "❌ Fallo: Los permisos del archivo kube-proxy-config.yaml en el pod $i son $PERMISSIONS. Deben ser 644 o más restrictivos."
    exit 1
  else
    echo "✅ Permisos del archivo kube-proxy-config.yaml en el pod $i son correctos: $PERMISSIONS"
  fi
done

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: Los permisos del archivo de configuración de kube-proxy son correctos en todos los pods."
exit 0
