#!/usr/bin/env sh
CLUSTER_NAME="${CLUSTER_NAME:-defaultApp}"
terraform init
terraform workspace select dev
terraform apply -var "cluster_name=$CLUSTER_NAME" --auto-approve