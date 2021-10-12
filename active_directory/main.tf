variable "vpc_id" {}
variable "subnet_ids" {}
variable "name" {
  type    = string
  default = "corp.keithrozario.com"
}

resource "random_password" "this" {
  length           = 12
  special          = false
  min_lower = 1
  min_numeric = 1
  min_special = 1
  min_upper = 1
}

variable "common_tags" {
  type = map(any)
  default = {
    source = "Terraform"
  }
}

resource "aws_directory_service_directory" "domain_controller" {
  name     = var.name
  password = random_password.this.result
  edition  = "Standard"
  type     = "MicrosoftAD"

  vpc_settings {
    vpc_id     = var.vpc_id
    subnet_ids = var.subnet_ids
  }

  tags = merge(
    { Name = "DomainController" },
  var.common_tags)
}


output "domain_controller_id" {
  value = aws_directory_service_directory.domain_controller.id
}

output "domain_controller_name" {
  value = aws_directory_service_directory.domain_controller.name
}

output "domain_controler_dns_ip_addresses" {
  value = sort(aws_directory_service_directory.domain_controller.dns_ip_addresses)
}

resource "aws_ssm_parameter" "password" {
  name  = "AD_Password"
  type  = "SecureString"
  value = random_password.this.result
}