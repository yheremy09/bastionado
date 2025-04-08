#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando la propiedad del archivo kube-proxy-config.yaml"

# 1️⃣ Verificar la propiedad del archivo kube-proxy en todos los pods de openshift-sdn
for i in $(oc get pods -n openshift-sdn -l app=sdn -o name)
do
  OWNER_GROUP=$(oc exec -n openshift-sdn $i -- stat -Lc %U:%G /config/kube-proxy-config.yaml)
  
  # Verificar si la propiedad es root:root
  if [ "$OWNER_GROUP" != "root:root" ]; then
    echo "❌ Fallo: La propiedad del archivo kube-proxy-config.yaml en el pod $i es $OWNER_GROUP. Debe ser root:root."
    exit 1
  else
    echo "✅ La propiedad del archivo kube-proxy-config.yaml en el pod $i es correcta: $OWNER_GROUP"
  fi
done

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: La propiedad del archivo kube-proxy-config.yaml es root:root en todos los pods."
exit 0
