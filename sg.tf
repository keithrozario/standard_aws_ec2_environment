resource "aws_security_group" "allow_all_egress" {
  name        = "Allow all egress"
  description = "Allow all egress"
  vpc_id      = module.vpc.vpc_id

  egress{
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
  }
  
  tags = {
    Name = "allow_all_egress"
  }
}

resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "Allow all ingress from internal"
  description = "Allow all ingress from internal"
  vpc_id      = module.vpc.vpc_id

  ingress{
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = [module.vpc.vpc_cidr_block]
  }
  
  tags = {
    Name = "vpc_endpoint_sg"
  }
}

resource "aws_security_group" "load_balancer_public" {
  name        = "load_balancer_public"
  description = "Allow https from the internet"
  vpc_id      = module.vpc.vpc_id

  egress{
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/16"]
  }

  ingress{
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"] 
  }
  
  tags = {
    Name = "load_balancer"
  }
}
