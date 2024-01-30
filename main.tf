terraform {
  required_providers {

    aws = {
      source  = "hashicorp/aws"
    }

  }
  cloud {
    organization = "aws-demos"

    workspaces {
      name = "kube-cluster"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs              = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  public_subnets   = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24" ]
  private_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]

  enable_nat_gateway               = true
  create_database_subnet_group     = true
  default_vpc_enable_dns_hostnames = true
  default_vpc_enable_dns_support   = true
  enable_dns_hostnames             = true
  enable_dns_support               = true
  map_public_ip_on_launch          = true

  public_subnet_tags  = merge(
    local.common_tags, 
    {"kubernetes.io/role/elb" = "1"}
  )

  private_subnet_tags = merge(
    local.common_tags, 
    {"karpenter.sh/discovery" = local.cluster_name},
    {"kubernetes.io/role/internal-elb" = "1"}
  )

  tags = local.common_tags
}


module "eks" {
  ## There's a warning everytime we apply this because of the issue below, ignore the "resolve_conflicts" warning.
  ## https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2635

  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true
  cluster_endpoint_private_access= true

  cluster_addons = {
    vpc-cni = {
      before_compute = true
      most_recent    = true
      configuration_values = jsonencode({
        env = {
          ENABLE_POD_ENI                    = "true"
          ENABLE_PREFIX_DELEGATION          = "true"
          POD_SECURITY_GROUP_ENFORCING_MODE = "standard"
        }

        enableNetworkPolicy = "true"
      })
    }
  }


  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 3
      max_size     = 6
      desired_size = 3

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
    }
  }
}

data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

data "aws_iam_policy" "efs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}


module "irsa-efs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"

  create_role                    = true
  role_name                      = "AmazonEKSTFEFSCSIRole-${module.eks.cluster_name}"
  provider_url                   = module.eks.oidc_provider
  role_policy_arns               = [data.aws_iam_policy.efs_csi_policy.arn]
  oidc_subjects_with_wildcards   = ["system:serviceaccount:kube-system:efs-csi-*"]
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

resource "aws_eks_addon" "ebs-csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.20.0-eksbuild.1"
  service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
  tags = {
    "eks_addon" = "ebs-csi"
    "terraform" = "true"
  }
}

resource "aws_eks_addon" "efs-csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-efs-csi-driver"
  addon_version            = "v1.7.4-eksbuild.1"
  service_account_role_arn = module.irsa-efs-csi.iam_role_arn
  tags = {
    "eks_addon" = "efs-csi"
    "terraform" = "true"
  }
}

module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "1.9.2"

  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller = {
    wait = true
  }

  cluster_name      = local.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = local.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn
}

module efs {
  source = "./efs"
  vpc_id = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  subnet_ids = module.vpc.private_subnets

}