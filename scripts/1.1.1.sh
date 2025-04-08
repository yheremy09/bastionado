for i in $( oc get pods -n openshift-kube-apiserver -l app=openshift-kube-apiserver -o name ) 
do 
PERMISSIONS=$(oc exec  -n openshift-kube-apiserver $i -- stat -c %a /etc/kubernetes/static-pod-resources/kube-apiserver-pod.yaml 2>/dev/null)
if [ "$PERMISSIONS" != "600" ]; then
    echo "Fallo en 1.1.1"
    exit 1
fi
done
echo "Éxito en 1.1.1"
exit 0
