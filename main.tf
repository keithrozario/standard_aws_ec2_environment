terraform {
  required_providers {

    aws = {
      source  = "hashicorp/aws"
    }

  }
  cloud {
    organization = "aws-demos"

    workspaces {
      name = "vpc-fsx"
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

  azs              = ["ap-southeast-1a", "ap-southeast-1b"]
  public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  database_subnets = ["10.0.201.0/24", "10.0.202.0/24"]

  enable_nat_gateway               = true
  create_database_subnet_group     = true
  default_vpc_enable_dns_hostnames = true
  default_vpc_enable_dns_support   = true
  enable_dns_hostnames             = true
  enable_dns_support               = true
  map_public_ip_on_launch          = true

  tags = local.common_tags
}

# module "alb" {
#   source  = "terraform-aws-modules/alb/aws"
#   version = "~> 8.0"

#   name = "load-balancer-public"

#   load_balancer_type = "application"

#   vpc_id             = module.vpc.vpc_id
#   subnets            = module.vpc.public_subnets
#   security_groups    = [aws_security_group.load_balancer_public.id]
# }

# module "windows_ec2" {
#  source                 = "./ec2_windows"
#  subnet_ids             = [module.vpc.private_subnets[0]]
#  vpc_security_group_ids = [module.vpc.default_security_group_id]
#  common_tags            = local.common_tags
# #  ami_name = "Windows_Server-2019-English-Full-SQL_2019_Web*"
# }

module "linux_ec2" {
  source                 = "./ec2_linux"
  subnet_ids             = module.vpc.private_subnets
  vpc_security_group_ids = [aws_security_group.allow_all_egress.id]
  common_tags            = local.common_tags
}

# module "AD" {
# # The amin password will be randomly generated and set inside a ssm parameter: "AD_Password"
#   source      = "./active_directory"
#   vpc_id      = module.vpc.vpc_id
#   subnet_ids  = module.vpc.private_subnets
#   common_tags = local.common_tags

# }

resource "aws_vpc_endpoint" "endpoints" {
  for_each = toset( ["ec2messages", "ssm", "ssmmessages"] )

  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  vpc_endpoint_type = "Interface"
  subnet_ids = module.vpc.private_subnets
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
}

# module "efs" {
#   source = "./efs"
#   subnet_ids  = module.vpc.private_subnets
#   vpc_id = module.vpc.vpc_id
#   vpc_cidr_block = module.vpc.vpc_cidr_block
# }

# module sftp {
#   source = "./transfer_family"
#   subnet_ids  = module.vpc.private_subnets
#   vpc_id = module.vpc.vpc_id
#   efs_id = module.efs.efs_id
#   vpc_cidr_block = module.vpc.vpc_cidr_block
# }

# module "AD" {
# # The amin password will be randomly generated and set inside a ssm parameter: "AD_Password"
#   source      = "./active_directory"
#   vpc_id      = module.vpc.vpc_id
#   subnet_ids  = module.vpc.private_subnets
#   common_tags = local.common_tags

# }

# module "connect_to_AD" {
#   source                            = "./connect_to_AD"
#   instance_ids                      = module.windows_ec2.instance_ids
#   ec2_role_name                     = module.windows_ec2.ec2_role_name
#   domain_controller_id              = module.AD.domain_controller_id
#   domain_controller_name            = module.AD.domain_controller_name
#   domain_controler_dns_ip_addresses = module.AD.domain_controler_dns_ip_addresses
# }

# module "fsx_for_windows" {
#   source = "./fsx_for_windows"
#   active_directory_id = module.AD.domain_controller_id
#   allowed_security_group_ids = [module.vpc.default_security_group_id]
#   subnet_ids             = module.vpc.private_subnets
#   deployment_type = "MULTI_AZ_1"
# }

# resource "aws_s3_bucket" "mult_buckets" {
#   count = 4 # Create 4 similar Buckets
#   bucket = "random-bucket-name-xxxxxxx-${count.index}"
# }

# module dns_record {
#   source = "./dns_record"
#   root_domain_name = "klayers.cloud"
#   sub_domain_name = "sub.klayers.cloud"
#   vpn_domain_name = "vpn.sub.klayers.cloud"
#   common_tags = local.common_tags
#   cloudflare_api_token = var.cloudflare_api_token
# }

# module client_vpn {
#   source = "./client_vpn"
#   active_directory_id = module.AD.domain_controller_id
#   vpc_id      = module.vpc.vpc_id
#   subnet_ids  = module.vpc.public_subnets
#   security_group_ids = [module.vpc.default_security_group_id]
#   target_network_cidr = module.vpc.vpc_cidr_block
# }

# module dns_firewall {
#   source = "./dns_firewall"
#   vpc_id = module.vpc.vpc_id
#   common_tags = local.common_tags
# }

# module private_hosted_zone {
#   source = "./private_hosted_zone"
#   vpc_id = module.vpc.vpc_id
# }

# module "db" {
#   source = "./rds"
#   subnet_ids = module.vpc.database_subnets
#   vpc_id = module.vpc.vpc_id
#   vpc_cidr_block = module.vpc.vpc_cidr_block
# }


# module "tgw" {
#   source  = "terraform-aws-modules/transit-gateway/aws"
#   version = "~> 2.0"

#   name        = "tgw-terraform"

#   enable_auto_accept_shared_attachments = true

#   vpc_attachments = {
#     vpc = {
#       vpc_id       = module.vpc.vpc_id
#       subnet_ids   = module.vpc.private_subnets
#       dns_support  = true
#       ipv6_support = true

#       tgw_routes = [
#         {
#           destination_cidr_block = "30.0.0.0/16"
#         },
#         {
#           blackhole = true
#           destination_cidr_block = "40.0.0.0/20"
#         }
#       ]
#     }
#   }

#   ram_allow_external_principals = true
#   ram_principals = [307990089504]

#   tags = {
#     Purpose = "tgw-complete-example"
#   }
# }
