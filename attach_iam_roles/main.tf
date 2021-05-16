## Attaches necessary policies to Instances
## Applicable to both linux and windows machines
## Additional policies can be added separately

variable "iam_role_name" {}

resource "aws_iam_role" "this" {
  name = var.iam_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_instance_profile" "this" {
  name = var.iam_role_name
  role = aws_iam_role.this.name
}

#### Policies and attachments
data "aws_iam_policy" "ssm_managed_instance_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "cloudwatch_agent_policy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_attach" {
  role       = aws_iam_role.this.name
  policy_arn = data.aws_iam_policy.ssm_managed_instance_policy.arn
}

resource "aws_iam_role_policy_attachment" "cloud_watch_agent_attach" {
  role       = aws_iam_role.this.name
  policy_arn = data.aws_iam_policy.cloudwatch_agent_policy.arn
}

output "iam_role_name" {
  value = var.iam_role_name
}
