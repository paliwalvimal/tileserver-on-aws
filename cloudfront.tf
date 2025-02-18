locals {
  tileserver_origin_id            = "${local.prefix}-tileserver"
  tileserver_authz_cf_header_name = "x-tileserver-authz-token"
}

resource "aws_cloudfront_function" "tileserver_response_headers" {
  name    = "${local.prefix}-tileserver-response-headers"
  code    = file("${path.module}/tileserver_response_headers.js")
  runtime = "cloudfront-js-2.0"
  publish = true
}

resource "random_password" "tileserver_cf_authz_token" {
  length      = 30
  special     = true
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
}

resource "aws_ssm_parameter" "tileserver_cf_authz_token" {
  # checkov:skip=CKV_AWS_337: CMK encryption not required
  name        = "/secret/cloudfront/${local.tileserver_authz_cf_header_name}"
  description = "Token for cloudfront custom header passed to tileserver lambda authorizer"
  type        = "SecureString"
  value       = random_password.tileserver_cf_authz_token.result
  tags        = var.tags
}

resource "aws_cloudfront_distribution" "tileserver" {
  # checkov:skip=CKV_AWS_310: Origin failover not required
  # checkov:skip=CKV_AWS_374: Geo restriction is managed via WAF
  # checkov:skip=CKV_AWS_305: Default root object not required
  # checkov:skip=CKV2_AWS_32: Response headers will be managed via CloudFront Functions
  # checkov:skip=CKV_AWS_86: Access logging v2 is enabled via awscc provider
  enabled         = true
  is_ipv6_enabled = true
  aliases         = [var.tileserver_domain_name]
  comment         = "Cloudfront distribution for tileserver HTTP API"
  price_class     = "PriceClass_All"
  web_acl_id      = aws_wafv2_web_acl.waf_tileserver.arn
  http_version    = "http2"

  origin {
    origin_id   = local.tileserver_origin_id
    domain_name = split("://", aws_apigatewayv2_api.tileserver.api_endpoint)[1]

    custom_header {
      name  = local.tileserver_authz_cf_header_name
      value = aws_ssm_parameter.tileserver_cf_authz_token.value
    }

    custom_origin_config {
      origin_protocol_policy = "match-viewer"
      http_port              = 80
      https_port             = 443
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = local.tileserver_origin_id
    compress                 = true
    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # Managed-CachingDisabled
    origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac" # Managed-AllViewerExceptHostHeader

    function_association {
      event_type   = "viewer-response"
      function_arn = aws_cloudfront_function.tileserver_response_headers.arn
    }
  }

  restrictions {
    # Geo restriction is managed via WAF
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.create_ssl_cert ? module.tileserver_ssl[0].arn : var.tileserver_acm_cert_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  tags = var.tags
}

resource "aws_route53_record" "tileserver" {
  count           = var.create_tileserver_dns_record ? 1 : 0
  name            = var.tileserver_domain_name
  type            = "A"
  zone_id         = var.hosted_zone_id
  allow_overwrite = true

  alias {
    name                   = aws_cloudfront_distribution.tileserver.domain_name
    zone_id                = aws_cloudfront_distribution.tileserver.hosted_zone_id
    evaluate_target_health = false
  }
}

# using awscc provider because as of writing this, terraform aws provider
# does not fully support cloudfront logging v2 due to a bug
# ref: https://github.com/hashicorp/terraform-provider-aws/issues/40885
resource "awscc_logs_delivery_source" "tileserver_cf" {
  provider     = awscc.use1
  name         = "${local.prefix}-tileserver-cf"
  log_type     = "ACCESS_LOGS"
  resource_arn = aws_cloudfront_distribution.tileserver.arn
  tags         = [for k, v in var.tags : { key = k, value = v }]
}

resource "awscc_logs_delivery_destination" "tileserver_cf_s3" {
  provider                 = awscc.use1
  name                     = "${local.prefix}-tileserver-cf-s3"
  destination_resource_arn = module.tileserver_cf_access_logs_bucket.arn
  output_format            = "json"
  tags                     = [for k, v in var.tags : { key = k, value = v }]
}

resource "awscc_logs_delivery" "tileserver_cf_s3" {
  provider                 = awscc.use1
  delivery_source_name     = awscc_logs_delivery_source.tileserver_cf.name
  delivery_destination_arn = awscc_logs_delivery_destination.tileserver_cf_s3.arn
  tags                     = [for k, v in var.tags : { key = k, value = v }]
}
