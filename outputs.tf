output "tileserver_cf_authz_token_ssm_param_name" {
  value = aws_ssm_parameter.tileserver_cf_authz_token.name
}

output "tileserver_cf_authz_token_ssm_param_arn" {
  value = aws_ssm_parameter.tileserver_cf_authz_token.arn
}

output "tileserver_cloudfront_id" {
  value = aws_cloudfront_distribution.tileserver.id
}

output "tileserver_cloudfront_arn" {
  value = aws_cloudfront_distribution.tileserver.arn
}

output "tileserver_cloudfront_domain_name" {
  value = aws_cloudfront_distribution.tileserver.domain_name
}

output "tileserver_cloudfront_hosted_zone_id" {
  value = aws_cloudfront_distribution.tileserver.hosted_zone_id
}
