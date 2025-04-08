for i in $( oc get pods -n openshift-kube-controller-manager -l app=kube-controller-manager -o name ) 
do 
PERMISSIONS=$(oc exec  -n openshift-kube-controller-manager $i -- stat -c %a /etc/kubernetes/static-pod-resources/kube-controller-manager-pod.yaml 2>/dev/null)
if [ "$PERMISSIONS" != "600" ]; then
    echo "Fallo en 1.1.3"
    exit 1
fi
done
echo "Éxito en 1.1.3"
exit 0
