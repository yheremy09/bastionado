RESULT=$(oc get namespaces -o json | jq -r '.items[] | select(.metadata.name | test("(?!default|kube-.|openshift.)^.*")) | .metadata.name')


if [[ -n "$RESULT" ]]; then
    echo "Éxito en 5.7.1: Se encontraron namespaces válidos."
    exit 0
else
    echo "Fallo en 5.7.1: No se encontraron namespaces válidos."
    exit 1
fi
