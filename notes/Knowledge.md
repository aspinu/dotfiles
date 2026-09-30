## Kubernetes


>[!IMPORTANT]Create secret
```
kubectl get secret cloudflare-api-key-secret -n cert-manager -o jsonpath='{.data.api-token}' | base64 --decode; echo
kubectl create secret generic cloudflare-api-key-secret --namespace=cert-manager --from-literal=api-token='secret value'
```

>[!IMPORTANT]Force delete crds
```
kubectl delete crd challenges.acme.cert-manager.io --force --grace-period=0;
kubectl patch crd challenges.acme.cert-manager.io -p '{"metadata":{"finalizers":[]}}' --type=merge
```



----
