variable vpc_id {}
variable subnet_ids {}
variable name {
    type = string
    default = "corp.keithrozario.com"
}
variable password {
    type = string
    default = "SuperSecretPassw0rd"
}

variable common_tags {
  type = map
  default = {
    source = "Terraform"
  }
}


resource "aws_directory_service_directory" "domain_controller" {
  name     = var.name
  password = var.password
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


output domain_controller_id {
  value = aws_directory_service_directory.domain_controller.id
}

output domain_controller_name {
  value = aws_directory_service_directory.domain_controller.name
}

output domain_controler_dns_ip_addresses {
  value = sort(aws_directory_service_directory.domain_controller.dns_ip_addresses)
}
