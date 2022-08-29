resource "aws_kms_key" "a" {
  description             = "EBS Volume Key"
  deletion_window_in_days = 7
  policy = data.aws_iam_policy_document.key_policy.json
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "key_policy" {
  statement {
    # Ensure account's root user retains access to key
    # even if access is removed for all other principals or those principals are removed
    sid = "AllowRootUserToAdministerKey"

    effect = "Allow"
    
    actions = ["kms:*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    resources = ["*"]
  }

  statement {
    sid = "AllowCrossAccountAccess"
    effect = "Allow"
    actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
    ]
    principals {
        type = "AWS"
        identifiers = [
          "arn:aws:sts::346684856104:assumed-role/Admin/krozario-Isengard"
        ]
    }
    resources = ["*"]
  }

  statement {
    sid = "Allow attachment of persistent resources"
    effect = "Allow"
    actions = [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
    ]
    principals {
        type = "AWS"
        identifiers = [
          "arn:aws:sts::346684856104:assumed-role/Admin/krozario-Isengard"
        ]
    }
    condition {
      test = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values = [true]

    }
    resources = ["*"]
  }

}

output kms_key_id {
    value = aws_kms_key.a.key_id
}