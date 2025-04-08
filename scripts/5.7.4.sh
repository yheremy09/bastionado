RESULT=$(oc get all -n default -o json 2>/dev/null | jq '.items[] | select((.kind|test("Service")) and (.metadata.name|test("openshift|kubernetes"))? | not) | (.kind + "/" + .metadata.name)')
if [ ${#RESULT} -ne 0 ]; then
    echo "Fallo en 5.7.4"
    exit 1
else
echo "Éxito en 5.7.4"
exit 0
fi
