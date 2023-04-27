resource "aws_iam_role" "user" {
  name = "transfer-family-sftp-user"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "user" {
  name = "transfer-family-sftp-user"
  role = aws_iam_role.user.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientRootAccess",
                "elasticfilesystem:ClientWrite",
                "elasticfilesystem:DescribeMountTargets"
            ],
            "Resource": "arn:aws:elasticfilesystem:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:file-system/${var.efs_id}"
        }
    ]
}
POLICY
}

resource "aws_transfer_user" "this" {
  server_id = aws_transfer_server.this.id
  user_name = "user"
  role      = aws_iam_role.user.arn

  home_directory_type = "LOGICAL"
  home_directory_mappings {
    entry  = "/"
    target = "/${var.efs_id}"
  }
  posix_profile {
    uid = var.posix_user_id
    gid = var.posix_group_id
    secondary_gids = length(var.posix_secondary_gids) == 0 ? null : var.posix_secondary_gids
  }
}

resource "aws_transfer_ssh_key" "example" {
  server_id = aws_transfer_server.this.id
  user_name = aws_transfer_user.this.user_name
  body      = file("${path.module}/transfer-key.pub")
}


