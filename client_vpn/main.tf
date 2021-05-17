variable subnet_ids {}
variable active_directory_id {}
variable security_group_ids {}
variable target_network_cidr {}
variable vpc_id {}
variable client_cidr_block{
    type = string
    default = "10.1.0.0/22"
}


resource "aws_ec2_client_vpn_endpoint" "this" {
  description            = "Client-2-Site VPN"
  server_certificate_arn = aws_acm_certificate.server.arn
  client_cidr_block      = var.client_cidr_block
  split_tunnel = true

  authentication_options {
    type                       = "directory-service-authentication"
    active_directory_id = var.active_directory_id
  }

  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.clientVPN.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.clientVPN.name
  }
}

resource "aws_security_group" "vpn_endpoint" {
  name        = "vpn_endpoint"
  description = "VPN endpoint Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "udp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 1194
    to_port          = 1194
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 1194
    to_port          = 1194
    protocol         = "udp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    security_groups = var.security_group_ids
  }

  tags = {
    Name = "VPN Endpoint"
  }
}

resource "aws_security_group_rule" "example" {
  count = length(var.security_group_ids)

  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  source_security_group_id = aws_security_group.vpn_endpoint.id
  security_group_id        = var.security_group_ids[count.index]
}

resource "aws_ec2_client_vpn_network_association" "this" {
  count = length(var.subnet_ids)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = var.subnet_ids[count.index]
  security_groups = [aws_security_group.vpn_endpoint.id]
}

resource "aws_ec2_client_vpn_authorization_rule" "this" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = var.target_network_cidr
  authorize_all_groups   = true
}

# Certs
resource "aws_acm_certificate" "server" {
  private_key      = file("./client_vpn/easy-rsa/easyrsa3/pki/private/server.key")
  certificate_body = file("./client_vpn/easy-rsa/easyrsa3/pki/issued/server.crt")
  certificate_chain = file("./client_vpn/easy-rsa/easyrsa3/pki/ca.crt")
    tags = {
    Name = "VPNServerCert"
  }
}

# resource "aws_acm_certificate" "client" {
#   private_key      = file("./client_vpn/easy-rsa/easyrsa3/pki/private/client.key")
#   certificate_body = file("./client_vpn/easy-rsa/easyrsa3/pki/issued/client.crt")
#   certificate_chain = file("./client_vpn/easy-rsa/easyrsa3/pki/ca.crt")
#   tags = {
#     Name = "VPNClientCert"
#   }
# }


# Logging Groups
resource "aws_cloudwatch_log_group" "clientVPN" {
  name = "clientVPNConnect"
}

resource "aws_cloudwatch_log_stream" "clientVPN" {
  name           = "clientVPNConnect"
  log_group_name = aws_cloudwatch_log_group.clientVPN.name
}

output dns_name {
    value = aws_ec2_client_vpn_endpoint.this.dns_name
}