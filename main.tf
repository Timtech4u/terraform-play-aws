##################################################################################
# Global
##################################################################################


terraform {
  required_version = ">= 0.12.24"
}

provider "aws" {
  version = "~> 2.59.0"
  region  = var.region
}


##################################################################################
# EKS Cluster
##################################################################################


module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = var.cluster_name
  subnets      = module.vpc.private_subnets

  tags = {
    Environment = "learning"
  }

  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      name                          = "worker-group"
      instance_type                 = "t2.small"
      asg_desired_capacity          = 2
      asg_min_size                  = 2
      asg_max_size                  = 2
      autoscaling_enabled           = true
    }
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}


##################################################################################
# VPC
##################################################################################


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.6.0"

  name                 = "training-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

data "aws_availability_zones" "available" {}


##################################################################################
# IAM
##################################################################################


module "iam_user" {
  source = "terraform-aws-modules/iam/aws//modules/iam-user"

  name          = var.iam_username
  force_destroy = true

  pgp_key = "keybase:timtech4u"

  password_reset_required = false

  create_iam_user_login_profile = true

}

module "iam_group_with_policies" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"

  name = "superadmins"

  group_users = [
    var.iam_username
  ]

  attach_iam_self_management_policy = true

  custom_group_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]

}


##################################################################################
# Locking with DynamoDB
##################################################################################

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "tim-terraform-lock"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

}


##################################################################################
# Remote State on S3
##################################################################################

terraform {
  backend "s3" {
    bucket = "tim-terraform-backend"
    key = "terraform"
    dynamodb_table = "tim-terraform-lock"
  }
}