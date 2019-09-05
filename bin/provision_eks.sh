#!/usr/bin/env sh
CLUSTER_NAME="${CLUSTER_NAME:-defaultApp}"
aws eks update-kubeconfig --name $CLUSTER_NAME
# kubectl apply -f config-map-aws-auth_$CLUSTER_NAME.yaml
kubectl apply -f rbac-config.yaml
helm init --service-account tiller --upgrade
kubectl -n kube-system wait --for=condition=Ready pods/$(kubectl get pods -n  kube-system -l "name=tiller" -o jsonpath="{.items[0].metadata.name}")
helm install stable/cluster-autoscaler --name cluster-autoscaler --namespace kube-system --values=config/cluster-autoscaler.yaml
helm install stable/nginx-ingress --name nginx-ingress --set rbac.create=true
helm install stable/kubernetes-dashboard --name dashboard --set rbac.clusterAdminRole=true
echo "Please run the following command to get dashboad access token: \n\tkubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep tiller | awk '{print $1}')"