locals {
  prefix = var.env
}

data "aws_route53_zone" "tileserver" {
  count   = var.create_tileserver_dns_record || var.create_ssl_cert ? 1 : 0
  zone_id = var.hosted_zone_id
}
