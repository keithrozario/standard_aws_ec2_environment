variable active_directory_id {}
variable subnet_ids {}
variable allowed_security_group_ids {}

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

# resource "aws_kms_key" "this" {
#   description             = "Key for FSX for Windows"
#   deletion_window_in_days = 7
# }

resource "aws_fsx_windows_file_system" "this" {
  active_directory_id = var.active_directory_id
#   kms_key_id          = aws_kms_key.this.arn
  storage_capacity    = var.storage_capacity
  subnet_ids           = var.subnet_ids
  throughput_capacity = var.throughput_capacity
}

output dns_name {
    value = aws_fsx_windows_file_system.this.dns_name
}

output id {
    value = aws_fsx_windows_file_system.this.id
}