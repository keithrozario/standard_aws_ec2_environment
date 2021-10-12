resource "aws_security_group" "allow_from_vpc" {
  name        = "Allow_from_vpc"
  description = "Allow inbound traffic from VPC"
  vpc_id      = var.vpc_id

  ingress{
      description      = "3306 from VPC"
      from_port        = 3306
      to_port          = 3306
      protocol         = "tcp"
      cidr_blocks      = [var.vpc_cidr_block]
    }

  tags = {
    Name = "RDS_SG"
  }
}