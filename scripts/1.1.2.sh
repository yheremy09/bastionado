for i in $( oc get pods -n openshift-kube-apiserver -l app=openshift-kube-apiserver -o name ) 
do 
PERMISSIONS=$(oc exec  -n openshift-kube-apiserver $i -- stat -c %U:%G /etc/kubernetes/static-pod-resources/kube-apiserver-pod.yaml 2>/dev/null)
if [ "$PERMISSIONS" != "root:root" ]; then
    echo "Fallo en 1.1.2"
    exit 1
fi
done
echo "Éxito en 1.1.2"
exit 0
