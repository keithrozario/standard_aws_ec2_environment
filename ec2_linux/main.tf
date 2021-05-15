variable subnet_ids {}
variable vpc_security_group_ids {}
variable common_tags {
  type = map
  default = {
    source = "Terraform"
}
}
variable name {
  type = string
  default = "LinuxServer"
}
variable instance_type {
  type = string
  default = "t3.large"
}

# AMI
data "aws_ami" "amazon-linux-2" {
  owners = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_instance" "this" {
  count = length(var.subnet_ids)

  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[count.index]
  vpc_security_group_ids = var.vpc_security_group_ids
  iam_instance_profile   = aws_iam_instance_profile.this.name
  tags = merge(
    { Name = "${var.name}${count.index}" },
    { OS = "AmazonLinux" },
    var.common_tags)
}

# IAM Role
module "attach_iam_role" {
    source = "../attach_iam_roles"
    iam_role_name = "${var.name}Role"
}

output instance_ids {
   value = aws_instance.this[*].id
}

output ec2_role_name {
   value = "${var.name}Role"
}


