module "maptiler_ssl" {
  count  = var.create_ssl_cert ? 1 : 0
  source = "github.com/terrablocks/aws-acm-ssl-certificate.git?ref=a3f12c6" # v1.0.0

  domain_names = [var.tileserver_domain_name]
  hosted_zone  = data.aws_route53_zone.tileserver[0].name
  tags         = var.tags

  providers = {
    aws = aws.use1
  }
}
