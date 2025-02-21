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

output "waf_arn" {
  value       = var.cloudfront_enable_waf ? join("", aws_wafv2_web_acl.tileserver[*].arn) : null
  description = "ARN of WAF associated to CloudFront distribution"
}

output "waf_id" {
  value       = var.cloudfront_enable_waf ? join("", aws_wafv2_web_acl.tileserver[*].id) : null
  description = "ID of WAF associated to CloudFront distribution"
}

output "waf_name" {
  value       = var.cloudfront_enable_waf ? join("", aws_wafv2_web_acl.tileserver[*].name) : null
  description = "Name of WAF associated to CloudFront distribution"
}

output "apigw_cwlg_arn" {
  value       = aws_cloudwatch_log_group.tileserver_api_logs.arn
  description = "ARN of CloudWatch log group created to store API Gateway access logs"
}

output "apigw_cwlg_name" {
  value       = aws_cloudwatch_log_group.tileserver_api_logs.name
  description = "Name of CloudWatch log group created to store API Gateway access logs"
}

output "apigw_vpc_link_name" {
  value       = aws_apigatewayv2_vpc_link.tileserver.name
  description = "Name of VPC Private link created for HTTP API Gateway"
}

output "apigw_vpc_link_id" {
  value       = aws_apigatewayv2_vpc_link.tileserver.id
  description = "ID of VPC Private link created for HTTP API Gateway"
}

output "apigw_vpc_link_arn" {
  value       = aws_apigatewayv2_vpc_link.tileserver.arn
  description = "ARN of VPC Private link created for HTTP API Gateway"
}

output "apigw_lambda_authz_name" {
  value       = var.apigw_create_lambda_authz ? join("", aws_iam_role.tileserver_apigw_lambda_authorizer[*].name) : null
  description = "Name of Lambda authorizer function created for API Gateway"
}

output "apigw_lambda_authz_arn" {
  value       = var.apigw_create_lambda_authz ? join("", aws_iam_role.tileserver_apigw_lambda_authorizer[*].arn) : null
  description = "ARN of Lambda authorizer function created for API Gateway"
}

output "apigw_lambda_authz_cwlg_arn" {
  value       = var.apigw_create_lambda_authz ? join("", aws_cloudwatch_log_group.tileserver_apigw_lambda_authorizer[*].arn) : null
  description = "ARN of CloudWatch log group created to store Lambda authorizer logs"
}

output "apigw_lambda_authz_cwlg_name" {
  value       = var.apigw_create_lambda_authz ? join("", aws_cloudwatch_log_group.tileserver_apigw_lambda_authorizer[*].name) : null
  description = "Name of CloudWatch log group created to store Lambda authorizer logs"
}

output "apigw_name" {
  value       = aws_apigatewayv2_api.tileserver.name
  description = "Name of the HTTP API Gateway"
}

output "apigw_id" {
  value       = aws_apigatewayv2_api.tileserver.id
  description = "ID of the HTTP API Gateway"
}

output "apigw_arn" {
  value       = aws_apigatewayv2_api.tileserver.arn
  description = "ARN of the HTTP API Gateway"
}

output "apigw_endpoint" {
  value       = aws_apigatewayv2_api.tileserver.api_endpoint
  description = "Random URL assigned to the HTTP API Gateway by AWS"
}

output "cloud_map_svc_discovery_namespace_name" {
  value       = aws_service_discovery_private_dns_namespace.tileserver.name
  description = "Name of the Cloud Map service discovery namespace"
}

output "cloud_map_svc_discovery_namespace_id" {
  value       = aws_service_discovery_private_dns_namespace.tileserver.id
  description = "ID of the Cloud Map service discovery namespace"
}

output "cloud_map_svc_discovery_namespace_arn" {
  value       = aws_service_discovery_private_dns_namespace.tileserver.arn
  description = "ARN of the Cloud Map service discovery namespace"
}

output "cloud_map_svc_discovery_svc_name" {
  value       = aws_service_discovery_service.tileserver.name
  description = "Name of the Cloud Map service discovery service"
}

output "cloud_map_svc_discovery_svc_id" {
  value       = aws_service_discovery_service.tileserver.id
  description = "ID of the Cloud Map service discovery service"
}

output "cloud_map_svc_discovery_svc_arn" {
  value       = aws_service_discovery_service.tileserver.arn
  description = "ARN of the Cloud Map service discovery service"
}
