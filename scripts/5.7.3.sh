oc get pods -A -o json | jq '.items[] | select(.metadata.annotations."openshift.io/scc"|test("privileged"?)) | .metadata.name'
