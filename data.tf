data "aws_security_group" "workspacesSG" {
  id = "sg-0d8d009304a2d2e61"
}

resource "aws_security_group" "allow_ingress_from_workspaces" {
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
    from_port        = 3389
    to_port          = 3389
    protocol         = "tcp"
    security_groups = [data.aws_security_group.workspacesSG.id]

  }
  
  tags = {
    Name = "allow_ingress_from_workspaces"
  }
}

locals {
  common_tags = {
    project = "WindowsFSX"
  }
}