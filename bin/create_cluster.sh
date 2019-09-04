#!/usr/bin/env sh
terraform init
terraform workspace select dev
terraform apply --auto-approve