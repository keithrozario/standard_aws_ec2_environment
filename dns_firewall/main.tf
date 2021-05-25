variable common_tags {}
variable vpc_id {}

resource "aws_route53_resolver_firewall_domain_list" "this" {
  name    = "example"
  domains = [
      "google.com",
      "keithrozario.com",
      "www.amazon.com"]
  tags    = {}
}

resource "aws_route53_resolver_firewall_rule_group" "this" {
  name = "example"
  tags = var.common_tags
}

resource "aws_route53_resolver_firewall_rule" "this" {
  name                    = "Block Google"
  action                  = "BLOCK"
  block_response          = "NXDOMAIN"
  firewall_domain_list_id = aws_route53_resolver_firewall_domain_list.this.id
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.this.id
  priority                = 100
}

resource "aws_route53_resolver_firewall_rule_group_association" "example" {
  name                   = "example"
  firewall_rule_group_id = aws_route53_resolver_firewall_rule_group.this.id
  priority               = 200
  vpc_id                 = var.vpc_id
}