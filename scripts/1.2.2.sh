#!/bin/bash

# Verificar que la autenticación básica no esté habilitada
BASIC_AUTH_CHECK=$(oc -n openshift-kube-apiserver get cm config -o yaml 2>/dev/null | grep "basic-auth" || \
                   oc -n openshift-apiserver get cm config -o yaml 2>/dev/null | grep "basic-auth")

if [[ -n "$BASIC_AUTH_CHECK" ]]; then
    echo "Fallo en 1.2.2 - Se detectó autenticación básica habilitada"
    exit 1
fi

# Verificar que el operador de autenticación está disponible
AUTH_OPERATOR_STATUS=$(oc get clusteroperator authentication --no-headers 2>/dev/null | awk '{print $3}')

if [[ "$AUTH_OPERATOR_STATUS" != "True" ]]; then
    echo "Fallo en 1.2.2 - El operador de autenticación no está disponible"
    exit 1
fi

# Si todas las verificaciones pasaron
echo "Éxito en 1.2.2"
exit 0
