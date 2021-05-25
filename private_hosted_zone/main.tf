variable vpc_id {}

resource "aws_route53_zone" "this" {
  name = "corpnetwork.com"
  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "www-dev" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "www"
  type    = "A"
  ttl     = "0"

  weighted_routing_policy {
    weight = 50
  }

  set_identifier = "dev"
  records        = ["192.168.0.1"]
}

resource "aws_route53_record" "www-live" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "www"
  type    = "A"
  ttl     = "0"

  weighted_routing_policy {
    weight = 50
  }

  set_identifier = "live"
  records        = ["192.168.0.2"]
}
