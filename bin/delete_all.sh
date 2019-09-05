#!/usr/bin/env sh
CLUSTER_NAME="${CLUSTER_NAME:-defaultApp}"
helm delete nginx-ingress
helm del --purge nginx-ingress
kubectl delete -f rbac-config.yaml
kubectl delete -f config-map-aws-auth_$CLUSTER_NAME.yaml
terraform destroy  -var "cluster_name=$CLUSTER_NAME" --auto-approve