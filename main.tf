terraform {
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "3.20.0"
    }

  }
}

provider "aws" {
  region = "ap-southeast-1"
}

variable cloudflare_api_token {}


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

  tags = local.common_tags
}

module "windows_ec2" {
  source                 = "./ec2_windows"
  subnet_ids             = module.vpc.private_subnets
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  common_tags            = local.common_tags
}

# module "linux_ec2" {
#   source                 = "./ec2_linux"
#   subnet_ids             = module.vpc.private_subnets
#   vpc_security_group_ids = [module.vpc.default_security_group_id]
#   common_tags            = local.common_tags
# }

module "AD" {
  source      = "./active_directory"
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets
  common_tags = local.common_tags
}

module "connect_to_AD" {
  source                            = "./connect_to_AD"
  instance_ids                      = module.windows_ec2.instance_ids
  ec2_role_name                     = module.windows_ec2.ec2_role_name
  domain_controller_id              = module.AD.domain_controller_id
  domain_controller_name            = module.AD.domain_controller_name
  domain_controler_dns_ip_addresses = module.AD.domain_controler_dns_ip_addresses
}

module "fsx_for_windows" {
  source = "./fsx_for_windows"
  active_directory_id = module.AD.domain_controller_id
  subnet_ids             = [module.vpc.private_subnets[0]]
  allowed_security_group_ids = [module.vpc.default_security_group_id]
}

module dns_record {
  source = "./dns_record"
  root_domain_name = "klayers.cloud"
  sub_domain_name = "sub.klayers.cloud"
  vpn_domain_name = "vpn.sub.klayers.cloud"
  common_tags = local.common_tags
  cloudflare_api_token = var.cloudflare_api_token
}

module client_vpn {
  source = "./client_vpn"
  active_directory_id = module.AD.domain_controller_id
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.public_subnets
  security_group_ids = [module.vpc.default_security_group_id]
  target_network_cidr = module.vpc.vpc_cidr_block
}
