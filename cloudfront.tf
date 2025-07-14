locals {
  tileserver_origin_id            = "${local.prefix}-tileserver"
  tileserver_authz_cf_header_name = "x-tileserver-authz-token"
}

resource "aws_cloudfront_function" "tileserver_response_headers" {
  count   = var.create_cloudfront_function ? 1 : 0
  name    = "${local.prefix}-tileserver-response-headers"
  runtime = "cloudfront-js-2.0"
  publish = true
  code = templatefile("${path.module}/tileserver_response_headers.js", {
    cors_origin_domain = var.cors_origin_domain
  })
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
  description = "AuthZ token for cloudfront custom header that is passed to tileserver lambda authorizer"
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
  # checkov:skip=CKV2_AWS_47: WAF association is user dependant
  enabled         = true
  is_ipv6_enabled = true
  aliases         = [var.tileserver_domain_name]
  comment         = "Cloudfront distribution for tileserver HTTP API"
  price_class     = var.cloudfront_price_class
  web_acl_id      = var.cloudfront_enable_waf ? join("", aws_wafv2_web_acl.tileserver[*].arn) : var.cloudfront_waf_id
  http_version    = var.cloudfront_http_version

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
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = local.tileserver_origin_id
    compress                   = true
    viewer_protocol_policy     = "redirect-to-https"
    cache_policy_id            = var.cloudfront_cache_policy_id
    origin_request_policy_id   = var.cloudfront_origin_request_policy_id
    response_headers_policy_id = var.cloudfront_response_headers_policy_id

    dynamic "function_association" {
      for_each = var.create_cloudfront_function ? [0] : []
      content {
        event_type   = "viewer-response"
        function_arn = join("", aws_cloudfront_function.tileserver_response_headers[*].arn)
      }
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
    acm_certificate_arn            = var.create_ssl_cert ? join("", module.tileserver_ssl[*].arn) : var.tileserver_acm_cert_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = var.cloudfront_minimum_protocol_version
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

resource "aws_cloudwatch_log_delivery_source" "tileserver_cf" {
  count        = var.cloudfront_enable_access_logs ? 1 : 0
  provider     = aws.use1
  name         = "${local.prefix}-tileserver-cf"
  log_type     = "ACCESS_LOGS"
  resource_arn = aws_cloudfront_distribution.tileserver.arn
  tags         = var.tags
}

resource "aws_cloudwatch_log_delivery_destination" "tileserver_cf_s3" {
  count    = var.cloudfront_enable_access_logs ? 1 : 0
  provider = aws.use1
  name     = "${local.prefix}-tileserver-cf-s3"

  delivery_destination_configuration {
    destination_resource_arn = var.create_cloudfront_logs_bucket ? join("", module.tileserver_cf_access_logs_bucket[*].arn) : var.cloudfront_access_logs_destination_arn
  }

  output_format = var.cloudfront_access_logs_format
  tags          = var.tags
}

resource "aws_cloudwatch_log_delivery" "tileserver_cf_s3" {
  count                    = var.cloudfront_enable_access_logs ? 1 : 0
  provider                 = aws.use1
  delivery_source_name     = join("", aws_cloudwatch_log_delivery_source.tileserver_cf[*].name)
  delivery_destination_arn = join("", aws_cloudwatch_log_delivery_destination.tileserver_cf_s3[*].arn)
  tags                     = var.tags
}
