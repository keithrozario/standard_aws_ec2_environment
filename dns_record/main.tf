variable root_domain_name {description = "the root domain of the cloudflare zone"}
variable sub_domain_name {description = "the sub domain to create the route53 zone"}
variable vpn_domain_name {description = "the domain within the subdomain for the vpn"}
variable "common_tags" {
  type = map(any)
  default = {
    source = "Terraform"
  }
}


resource "aws_route53_zone" "this" {
  name = var.sub_domain_name
  force_destroy = true

  tags = merge(
    { Name = "VPN-Domain" },
    var.common_tags)

}

data "cloudflare_zones" "this" {
  filter {
    name = var.root_domain_name
  }
}

resource "cloudflare_record" "NS_Records" {
  depends_on = [
    aws_route53_zone.this
  ]
  count = length(aws_route53_zone.this.name_servers)

  zone_id = data.cloudflare_zones.this.zones[0].id
  name    = var.sub_domain_name
  value   = aws_route53_zone.this.name_servers[count.index]
  type    = "NS"
  ttl     = 120
}