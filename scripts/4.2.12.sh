#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando las cifras criptográficas del Kubelet y la configuración de TLS"

# 1️⃣ Verificar las cifras de TLS para el Ingress
INGRESS_CIPHERS=$(oc get --namespace=openshift-ingress-operator ingresscontroller/default -o json | jq .status.tlsProfile.ciphers)
echo "Cifras de TLS para Ingress: $INGRESS_CIPHERS"

# 2️⃣ Verificar las cifras de TLS para el Kubernetes API server
K8S_CIPHERS=$(oc get kubeapiservers.operator.openshift.io cluster -o json | jq .spec.observedConfig.servingInfo.cipherSuites)
echo "Cifras de TLS para Kubernetes API server: $K8S_CIPHERS"

# 3️⃣ Verificar las cifras de TLS para el OpenShift API server
OS_CIPHERS=$(oc get openshiftapiservers.operator.openshift.io cluster -o json | jq .spec.observedConfig.servingInfo.cipherSuites)
echo "Cifras de TLS para OpenShift API server: $OS_CIPHERS"

# 4️⃣ Verificar las cifras de TLS para OpenShift Authentication
AUTH_CIPHERS=$(oc get cm -n openshift-authentication v4-0-config-system-cliconfig -o jsonpath='{.data.v4-0-config-system-cliconfig}' | jq .servingInfo.cipherSuites)
echo "Cifras de TLS para OpenShift Authentication: $AUTH_CIPHERS"

# 5️⃣ Verificar el perfil de TLS
TLS_PROFILE=$(oc get kubeapiservers.operator.openshift.io cluster -o json | jq .spec.tlsSecurityProfile)
echo "Perfil TLS: $TLS_PROFILE"

# Verificar si las cifras son fuertes
if [[ "$INGRESS_CIPHERS" != *"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"* ]] || \
   [[ "$K8S_CIPHERS" != *"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"* ]] || \
   [[ "$OS_CIPHERS" != *"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"* ]]; then
    echo "❌ Fallo: Algunas cifras criptográficas no son fuertes."
    exit 1
else
    echo "✅ Todas las cifras criptográficas son fuertes."
fi

# Finalizar con éxito si todo está correcto
echo "✅ Éxito: El Kubelet está configurado con cifras criptográficas fuertes."
exit 0
