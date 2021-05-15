# resource "aws_instance" "Linux" {
#   count = 1
#   ami                    = data.aws_ami.amazon-linux-2.id
#   instance_type          = "t3.large"
#   subnet_id              = module.vpc.private_subnets[count.index]
#   vpc_security_group_ids = [module.vpc.default_security_group_id]
#   iam_instance_profile   = aws_iam_instance_profile.this.name
#   tags = merge(
#     { Name = "LinuxServer${count.index}" },
#     { OS = "AmazonLinux" },
#     local.common_tags)
# }

# data "aws_ami" "amazon-linux-2" {
#   owners = ["amazon"]
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-ebs"]
#   }
# }

# # IAM Role
# resource "aws_iam_role" "ec2_role_linux" {
#   name = "LinuxAppServer"

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

# resource "aws_iam_instance_profile" "LinuxProfile" {
#   name = "LinuxServerProfileRole"
#   role = aws_iam_role.ec2_role_linux.name
# }


# #### Policies and attachments
# resource "aws_iam_role_policy_attachment" "ec2_ssm_attach_linux" {
#   role       = aws_iam_role.ec2_role_linux.name
#   policy_arn = data.aws_iam_policy.ssm_managed_instance_policy.arn
# }

# resource "aws_iam_role_policy_attachment" "cloud_watch_agent_attach_linux" {
#   role       = aws_iam_role.ec2_role_linux.name
#   policy_arn = data.aws_iam_policy.cloudwatch_agent_policy.arn
# }