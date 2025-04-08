#!/bin/bash

# Echo mensaje inicial
echo "🔍 Verificando que el API Server usa cifrados criptográficos fuertes"

# 1️⃣ Verificar los cifrados utilizados por el operador de autenticación
AUTH_CIPHERS=$(oc get cm -n openshift-authentication v4-0-config-system-cliconfig -o jsonpath='{.data.v4\-0\-config\-system\-cliconfig}' | jq .servingInfo)

# Verificar si la configuración es apropiada (no debe usar "Old" ni versiones de TLS bajas)
if echo "$AUTH_CIPHERS" | grep -q "Old"; then
    echo "❌ Fallo: El operador de autenticación usa un perfil de cifrado obsoleto (Old)."
    exit 1
fi

# 2️⃣ Verificar los cifrados utilizados por el operador de API Server de Kubernetes
KUBE_CIPHERS=$(oc get kubeapiservers.operator.openshift.io cluster -o json | jq .spec.observedConfig.servingInfo)

if echo "$KUBE_CIPHERS" | grep -q "Old"; then
    echo "❌ Fallo: El operador de API Server de Kubernetes usa un perfil de cifrado obsoleto (Old)."
    exit 1
fi

# 3️⃣ Verificar los cifrados utilizados por el operador de API Server de OpenShift
OPENSHIFT_CIPHERS=$(oc get openshiftapiservers.operator.openshift.io cluster -o json | jq .spec.observedConfig.servingInfo)

if echo "$OPENSHIFT_CIPHERS" | grep -q "Old"; then
    echo "❌ Fallo: El operador de API Server de OpenShift usa un perfil de cifrado obsoleto (Old)."
    exit 1
fi

# 4️⃣ Verificar los cifrados utilizados por el operador de Ingress
INGRESS_CIPHERS=$(oc get -n openshift-ingress-operator ingresscontroller/default -o json | jq .status.tlsProfile)

if echo "$INGRESS_CIPHERS" | grep -q "Old"; then
    echo "❌ Fallo: El operador de Ingress usa un perfil de cifrado obsoleto (Old)."
    exit 1
fi

# 5️⃣ Verificar que minTLSVersion no esté configurado como VersionTLS10 o VersionTLS11
MIN_TLS_VERSION=$(echo "$KUBE_CIPHERS" | jq '.minTLSVersion')

if [[ "$MIN_TLS_VERSION" == "VersionTLS10" || "$MIN_TLS_VERSION" == "VersionTLS11" ]]; then
    echo "❌ Fallo: La versión mínima de TLS está configurada incorrectamente ($MIN_TLS_VERSION)."
    exit 1
fi

# 6️⃣ Verificar que minTLSVersion sea al menos VersionTLS12
if [[ "$MIN_TLS_VERSION" == "VersionTLS12" || "$MIN_TLS_VERSION" == "VersionTLS13" ]]; then
    echo "✅ La versión mínima de TLS es apropiada ($MIN_TLS_VERSION)."
else
    echo "❌ Fallo: La versión mínima de TLS no es adecuada ($MIN_TLS_VERSION)."
    exit 1
fi

# Si todo pasa, imprimir éxito
echo "✅ Éxito: El API Server está usando cifrados criptográficos fuertes y TLS adecuado."
exit 0
