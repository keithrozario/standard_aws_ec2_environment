variable subnet_ids {}
variable vpc_id {}
variable vpc_cidr_block {}
variable efs_id {}
variable posix_user_id{
  type = string
  default = 0 # not recommended (effectively root) -- but only way to bootstrap an EFS volume
}
variable posix_group_id{
  type = string
  default = 0 # not recommended (effectively root) -- but only way to bootstrap an EFS volume
}
variable posix_secondary_gids{
  type = list
  default = []
}


data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_transfer_server" "this" {
  endpoint_type = "VPC"
  domain = "EFS"
  protocols = ["SFTP"]
  logging_role = aws_iam_role.cloudwatch_logs.arn
  security_policy_name = "TransferSecurityPolicy-2020-06"

  tags = {
    NAME = "std-aws"
  }

  endpoint_details {
    subnet_ids             = var.subnet_ids
    vpc_id                 = var.vpc_id
    security_group_ids     = [aws_security_group.transfer_family.id]
  }
}

resource "aws_security_group" "transfer_family" {
  name        = "Transfer Family Server"
  description = "Allow mount from VPC"
  vpc_id      = var.vpc_id

  ingress {
    description = "sftp from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    description = "NFS to EFS"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

}