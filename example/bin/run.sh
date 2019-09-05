#!/usr/bin/env sh
cd terraform
terraform apply --auto-approve
cd ../
kubectl apply -f deployment.yaml
