variable active_directory_id {}
variable subnet_ids {}

## Creates an FsX in the directory specified by active_directory_id
## Creates endpoints in subnet specified in subnets
## FsX endpoint is setup with the right security to connect to AD
## FsX endpoint is setup to allow any incoming traffic to it from within the vpc

variable deployment_type {
    type = string
    default = "SINGLE_AZ_1"
}

variable storage_capacity {
    type = number
    default = 64
}

variable throughput_capacity {
    type = number
    default = 32
}

resource "aws_fsx_windows_file_system" "this" {
  active_directory_id = var.active_directory_id
  storage_capacity    = var.storage_capacity
  subnet_ids           = var.subnet_ids
  throughput_capacity = var.throughput_capacity
  security_group_ids = [aws_security_group.this.id]
  deployment_type = var.deployment_type
  preferred_subnet_id = var.deployment_type == "MULTI_AZ_1" ? var.subnet_ids[0] : null
}

data "aws_directory_service_directory" "this" {
  directory_id = var.active_directory_id
}

locals {
    vpc_id = data.aws_directory_service_directory.this.vpc_settings[0].vpc_id
}

data "aws_vpc" "this" {
  id = local.vpc_id
}

resource "aws_security_group" "this" {
  name        = "fsx_security_group"
  description = "Allow traffic to domain controller, from all internal ips"
  vpc_id      = local.vpc_id

  ingress {
    description      = "Allow Internal Access 445"
    from_port        = 445
    to_port          = 445
    protocol         = "tcp"
    cidr_blocks      = [data.aws_vpc.this.cidr_block]
  }

  ingress {
    description      = "Allow Internal Access 5895"
    from_port        = 5895
    to_port          = 5895
    protocol         = "tcp"
    cidr_blocks      = [data.aws_vpc.this.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    security_groups  = [data.aws_directory_service_directory.this.security_group_id]
  }

  tags = {
    Name = "fsx_security_group"
  }
}

output dns_name {
    value = aws_fsx_windows_file_system.this.dns_name
}

output id {
    value = aws_fsx_windows_file_system.this.id
}