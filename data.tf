locals {
  common_tags = {
    project = "verified-access"
  }
}

resource "aws_security_group" "allow_all_egress" {
  name        = "allow_ingress_from_workspaces"
  description = "Allow RDP Ingress from workspaces"
  vpc_id      = module.vpc.vpc_id

  egress{
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
  }

  ingress{
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/16"]  # allow only from internal VPC
  }
  
  tags = {
    Name = "allow_all_egress"
  }
}

resource "aws_security_group" "load_balancer_sg" {
  name        = "load_balancer_sg"
  description = "Allow https from the internet"
  vpc_id      = module.vpc.vpc_id

  egress{
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/16"]
  }

  ingress{
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]  # allow only from internal VPC
  }
  
  tags = {
    Name = "load_balancer"
  }
}