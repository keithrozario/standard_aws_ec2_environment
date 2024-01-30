locals {
  common_tags = {
    project = "EKS"
  }
  cluster_name = "Kube-test"
  cluster_version = "1.28"
}

data "aws_region" "current" {}