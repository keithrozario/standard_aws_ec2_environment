locals {
  common_tags = {
    project = "WindowsFSX"
  }
}

data "aws_region" "current" {}