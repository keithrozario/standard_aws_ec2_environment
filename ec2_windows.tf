# # resource "aws_instance" "windows" {
# #   count = 2
# #   ami                    = data.aws_ami.windows.id
# #   instance_type          = "t3.large"
# #   subnet_id              = module.vpc.private_subnets[count.index]
# #   vpc_security_group_ids = [module.vpc.default_security_group_id]
# #   iam_instance_profile   = aws_iam_instance_profile.this.name
# #   tags = merge(
# #     { Name = "WinServer${count.index}" },
# #     { OS = "Windows-AD" },
# #     local.common_tags)
# # }

# # IAM Role
# resource "aws_iam_role" "ec2_role_windows" {
#   name = "windowsServerIAMRole"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF

# }

# resource "aws_iam_instance_profile" "this" {
#   name = "WindowsServerFSXProfileRole"
#   role = aws_iam_role.ec2_role_windows.name
# }


# #### Policies and attachments
# resource "aws_iam_role_policy_attachment" "ec2_ssm_attach_windows" {
#   role       = aws_iam_role.ec2_role_windows.name
#   policy_arn = data.aws_iam_policy.ssm_managed_instance_policy.arn
# }

# resource "aws_iam_role_policy_attachment" "cloud_watch_agent_attach_windows" {
#   role       = aws_iam_role.ec2_role_windows.name
#   policy_arn = data.aws_iam_policy.cloudwatch_agent_policy.arn
# }


# # AMI
# data "aws_ami" "windows" {
#     most_recent = true     

#     filter {
#        name   = "name"
#        values = ["Windows_Server-2019-English-Full-Base-*"]  
#     }
#     filter {
#         name   = "virtualization-type"
#         values = ["hvm"]  
#     }

#     owners = ["801119661308"] # Canonical
# }

# ## Security Group 
# resource "aws_security_group_rule" "allow_all" {
#   type              = "ingress"
#   to_port           = 0
#   protocol          = "-1"
#   source_security_group_id  = data.aws_security_group.workspacesSG.id
#   from_port         = 0
#   security_group_id = module.vpc.default_security_group_id
# }


