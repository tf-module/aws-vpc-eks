#!/usr/bin/env sh
helm delete nginx-ingress
helm del --purge nginx-ingress
terraform destroy