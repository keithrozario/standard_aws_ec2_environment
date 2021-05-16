data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_ssm_document" "ad-join-domain" {
  name          = "ad-join-domain"
  document_type = "Command"
  content = jsonencode(
    {
      "schemaVersion" = "2.2"
      "description"   = "aws:domainJoin"
      "mainSteps" = [
        {
          "action" = "aws:domainJoin",
          "name"   = "domainJoin",
          "inputs" = {
            "directoryId" : var.domain_controller_id,
            "directoryName" : var.domain_controller_name,
            "dnsIpAddresses" : var.domain_controler_dns_ip_addresses,
          }
        }
      ]
    }
  )
}

resource "aws_ssm_association" "ad_join_domain" {
  name = aws_ssm_document.ad-join-domain.name

  targets {
    key    = "InstanceIds"
    values = var.instance_ids
  }
}

resource "aws_iam_policy" "adAttachPolicy" {
  name        = "AssociatetoAD"
  path        = "/"
  description = "For seamless connection to AD"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:CreateAssociation",
          "ssm:UpdateAssociationStatus",
          "ssm:ListAssociation",
        "ssm:DescribeAssociation"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
        "ds:CreateComputer"]
        Effect   = "Allow"
        Resource = "arn:aws:ds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:directory/${var.domain_controller_id}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ad_attach" {
  role       = var.ec2_role_name
  policy_arn = aws_iam_policy.adAttachPolicy.arn
}