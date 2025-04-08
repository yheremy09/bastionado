
# Lista de pods que no deberían tener el token de la cuenta de servicio montado
PODS_NO_REQUIEREN_API=("alertmanager-main-0" "alertmanager-main-1" "prometheus-k8s-0" "prometheus-k8s-1" 
                       "kube-state-metrics-59fcb884bd-4cq7q" "node-exporter-2gnrj" "node-exporter-54d6c" 
                       "node-exporter-bn88f" "node-exporter-dtqjt" "node-exporter-hln2c" "node-exporter-jsmz6" 
                       "node-exporter-n2jbn" "node-exporter-z42h8" "external-secrets-5bccc7758-5lpk4" 
                       "external-secrets-cert-controller-f8c5cf67c-zsxrk" "external-secrets-webhook-ff45bd895-bjwq7")

# Convertir la lista de pods a un formato de regex
PODS_REGEX=$(printf "|%s" "${PODS_NO_REQUIEREN_API[@]}")
PODS_REGEX=${PODS_REGEX:1}

# Bandera para indicar si la auditoría pasa o falla
AUDITORIA_OK=true

# Verificar si algún pod de la lista tiene el token montado automáticamente
for POD in $(oc get pods -A -o json | jq '.items[] | select(.spec.automountServiceAccountToken) | .metadata.name'); do
    if [[ "$POD" =~ $PODS_REGEX ]]; then
        AUDITORIA_OK=false
    fi
done

# Verificar cuentas de servicio que montan automáticamente el token
TOKEN_MONTADO=$(oc get serviceaccounts -A -o json | jq '.items[] | select(.automountServiceAccountToken) | .metadata.name')
if [[ -n "$TOKEN_MONTADO" ]]; then
    AUDITORIA_OK=false
fi


# Resultado final
if $AUDITORIA_OK; then
    echo "Éxito en 5.1.6"
    exit 0
else
    echo "Fallo en 5.1.6"
    exit 1
fi


