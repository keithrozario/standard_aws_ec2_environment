variable subnet_ids {}
variable vpc_id {}
variable vpc_cidr_block {}

resource "aws_efs_file_system" "main" {
}

resource "aws_efs_mount_target" "this" {
  for_each = toset( var.subnet_ids )
  # deploys mount target for all subnets in VPC

  file_system_id = aws_efs_file_system.main.id
  subnet_id      = each.key
  security_groups = [aws_security_group.efs_mount_target.id]
}

resource "aws_security_group" "efs_mount_target" {
  name        = "EFS Mount Target"
  description = "Allow mount from VPC"
  vpc_id      = var.vpc_id

  ingress {
    description = "NFS from VPC"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

}

