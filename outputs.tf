output "tileserver_cf_authz_token_ssm_param_name" {
  value       = aws_ssm_parameter.tileserver_cf_authz_token.name
  description = "Name of SSM parameter used for storing authZ token shared between CloudFront and API Gateway"
}

output "tileserver_cf_authz_token_ssm_param_arn" {
  value       = aws_ssm_parameter.tileserver_cf_authz_token.arn
  description = "ARN of SSM parameter used for storing authZ token shared between CloudFront and API Gateway"
}

output "cloudfront_id" {
  value       = aws_cloudfront_distribution.tileserver.id
  description = "ID of CloudFront distribution"
}

output "cloudfront_arn" {
  value       = aws_cloudfront_distribution.tileserver.arn
  description = "ARN of CloudFront distribution"
}

output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.tileserver.domain_name
  description = "Domain name assigned to CloudFront distribution"
}

output "cloudfront_hosted_zone_id" {
  value       = aws_cloudfront_distribution.tileserver.hosted_zone_id
  description = "Hosted zone ID of CloudFront distribution"
}

output "s3_bucket_name" {
  value       = var.cloudfront_create_s3_bucket ? join("", module.tileserver_cf_access_logs_bucket[*].name) : null
  description = "Name of S3 bucket used to store CloudFront access logs"
}

output "s3_bucket_arn" {
  value       = var.cloudfront_create_s3_bucket ? join("", module.tileserver_cf_access_logs_bucket[*].arn) : null
  description = "ARN of S3 bucket used to store CloudFront access logs"
}
