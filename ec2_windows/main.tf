variable "subnet_ids" {}
variable "vpc_security_group_ids" {}
variable "common_tags" {
  type = map(any)
  default = {
    source = "Terraform"
  }
}
variable "name" {
  type    = string
  default = "WindowsServer"
}
variable "instance_type" {
  type    = string
  default = "t3.large"
}


# AMI
data "aws_ami" "windows" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["801119661308"] # Canonical
}

resource "aws_instance" "this" {
  count = length(var.subnet_ids)

  ami                    = data.aws_ami.windows.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[count.index]
  vpc_security_group_ids = var.vpc_security_group_ids
  iam_instance_profile   = module.attach_iam_role.iam_role_name
  tags = merge(
    { Name = "${var.name}${count.index}" },
    { OS = "Windows" },
  var.common_tags)
}

# IAM Role
module "attach_iam_role" {
  source        = "../attach_iam_roles"
  iam_role_name = var.name
}

output "instance_ids" {
  value = aws_instance.this[*].id
}

output "ec2_role_name" {
  value = module.attach_iam_role.iam_role_name
}