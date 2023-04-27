data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudwatch_logs" {
  name               = "transfer-family-logging"
  description        = "Logging Role for Transfer Family"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "cloudwatch_logging_policy" {
  statement {
    actions = [
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      format("arn:aws:logs:%s:%s:*", data.aws_region.current.name, data.aws_caller_identity.current.account_id)
    ]
  }
}

resource "aws_iam_role_policy" "main" {
  name   = "transfer-family-logging"
  role   = aws_iam_role.cloudwatch_logs.name
  policy = data.aws_iam_policy_document.cloudwatch_logging_policy.json
}