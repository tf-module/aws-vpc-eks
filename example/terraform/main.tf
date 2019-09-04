terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">= 2.11"
  region  = "us-east-1"
}

data "aws_route53_zone" "selected" {
  name         = "siglus.us"
  private_zone = false
}

data "kubernetes_service" "nginx-ingress-controller" {
  metadata {
    name = "nginx-ingress-controller"
  }
}

resource "aws_route53_record" "eks-lb-dns" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "eks"
  type    = "CNAME"
  ttl     = "300"
  records = ["${data.kubernetes_service.nginx-ingress-controller.load_balancer_ingress.0.hostname}"]
}
