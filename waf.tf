resource "aws_wafv2_web_acl" "tileserver" {
  # checkov:skip=CKV2_AWS_31: Logging will be managed by user
  count       = var.cloudfront_enable_waf ? 1 : 0
  provider    = aws.use1
  name        = "${local.prefix}-tileserver-waf-acl"
  description = "WAF Web ACL for tileserver"
  scope       = "CLOUDFRONT"

  lifecycle {
    create_before_destroy = true
  }

  default_action {
    dynamic "allow" {
      for_each = var.cors_origin_domain == "*" ? [0] : []
      content {}
    }

    dynamic "block" {
      for_each = var.cors_origin_domain == "*" ? [] : [0]
      content {}
    }
  }

  rule {
    name     = "block-countries-rule"
    priority = 0

    action {
      block {}
    }

    statement {
      geo_match_statement {
        country_codes = [
          "CU", # Cuba
          "IR", # Iran
          "KP", # N. Korea
          "RU", # Russia
          "SY"  # Syria
        ]
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.prefix}-tileserver-block-countries-rule-waf-acl"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "block-aws-default-domain"
    priority = 1

    action {
      block {}
    }

    statement {
      byte_match_statement {
        field_to_match {
          single_header {
            name = "host"
          }
        }
        positional_constraint = "ENDS_WITH"
        search_string         = ".cloudfront.net"
        text_transformation {
          type     = "NONE"
          priority = 0
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.prefix}-tileserver-block-aws-default-domain-waf-acl"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "aws-common-rule"
    priority = 100

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.prefix}-tileserver-common-rule-waf-acl"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "aws-ip-rule"
    priority = 101

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.prefix}-tileserver-ip-rule-waf-acl"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "aws-bad-input-rule"
    priority = 102

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.prefix}-tileserver-bad-input-rule-waf-acl"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "aws-anonymous-ip-rule"
    priority = 103

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.prefix}-tileserver-anonymous-ip-rule-waf-acl"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "aws-sql-rule"
    priority = 104

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.prefix}-tileserver-sql-rule-waf-acl"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "aws-linux-rule"
    priority = 105

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.prefix}-tileserver-linux-rule-waf-acl"
      sampled_requests_enabled   = true
    }
  }

  dynamic "rule" {
    for_each = var.cors_origin_domain == "*" ? [] : [0]

    content {
      name     = "whitelist-cors-domain"
      priority = 200

      action {
        allow {}
      }

      statement {
        byte_match_statement {
          positional_constraint = "EXACTLY"
          search_string         = var.cors_origin_domain

          field_to_match {
            single_header {
              name = "origin"
            }
          }

          text_transformation {
            priority = 0
            type     = "NONE"
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${local.prefix}-tileserver-whitelist-cors-domain-rule-waf-acl"
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.prefix}-tileserver-waf-acl"
    sampled_requests_enabled   = true
  }

  tags = var.tags
}
