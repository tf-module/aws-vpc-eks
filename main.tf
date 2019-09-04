terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">= 2.11"
  region  = local.aws_region
}

data "aws_availability_zones" "available" {
}

data "template_file" "private_subnet_cidrs" {
  template = cidrsubnet(local.vpc_cidr, 8, 2 * count.index)
  count    = local.az_count
}

data "template_file" "public_subnet_cidrs" {
  template = cidrsubnet(local.vpc_cidr, 8, 2 * count.index + 1)
  count    = local.az_count
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.6.0"

  name               = "${local.cluster_name}-${terraform.workspace}-vpc"
  cidr               = local.vpc_cidr
  azs                = data.aws_availability_zones.available.names
  private_subnets    = data.template_file.private_subnet_cidrs.*.rendered
  public_subnets     = data.template_file.public_subnet_cidrs.*.rendered
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared",
    Environment                                   = terraform.workspace
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "true"
  }
}

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = local.cluster_name
  vpc_id       = module.vpc.vpc_id
  subnets      = module.vpc.private_subnets
  tags = {
    Environment = terraform.workspace
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.small"
      asg_desired_capacity          = 2
    }
  ]
  cluster_security_group_id            = aws_security_group.all_worker_mgmt.id
  worker_additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
}
