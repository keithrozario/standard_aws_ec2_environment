# data "aws_security_group" "workspacesSG" {
#   id = "sg-0636c17643e41b430"
# }

locals {
  common_tags = {
    project = "WindowsFSX"
  }
}