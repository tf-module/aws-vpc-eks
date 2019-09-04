#!/usr/bin/env sh
CLUSTER_NAME=Siglus
# terraform init
# terraform workspace select dev
# terraform apply
aws eks update-kubeconfig --name $CLUSTER_NAME
kubectl apply -f config-map-aws-auth_$CLUSTER_NAME.yaml
cd k8s
kubectl apply -f rbac-config.yaml
helm init --service-account tiller --upgrade
helm install stable/nginx-ingress --name nginx-ingress --set rbac.create=true