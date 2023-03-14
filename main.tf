terraform {
  required_providers {

    aws = {
      source  = "hashicorp/aws"
    }

  }

  cloud {
    organization = "aws-demos"

    workspaces {
      name = "verified-access"
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

module "linux_ec2" {
  source                 = "./ec2_linux"
  subnet_ids             = [module.vpc.private_subnets[0]]
  vpc_security_group_ids = [aws_security_group.allow_all_egress.id]
  common_tags            = local.common_tags
}



module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "verified-access-alb"

  load_balancer_type = "application"

  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.load_balancer_sg.id]

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = {
        my_target = {
          target_id = module.linux_ec2.instance_ids[0]
          port = 80
        }
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = "arn:aws:acm:ap-southeast-1:047051505898:certificate/24e7f201-52af-48bd-82e3-ae605a595e63"
      target_group_index = 0
    }
  ]

}