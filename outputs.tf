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

output "cloudfront_ssl_cert_arn" {
  value       = var.create_ssl_cert ? join("", module.tileserver_ssl[*].arn) : var.tileserver_acm_cert_arn
  description = "ARN of SSL certificate attached to the CLoudFront distribution"
}

output "tileserver_cf_access_logs_bucket_name" {
  value       = var.create_cloudfront_logs_bucket ? join("", module.tileserver_cf_access_logs_bucket[*].name) : null
  description = "Name of S3 bucket used to store CloudFront access logs"
}

output "tileserver_cf_access_logs_bucket_arn" {
  value       = var.create_cloudfront_logs_bucket ? join("", module.tileserver_cf_access_logs_bucket[*].arn) : null
  description = "ARN of S3 bucket used to store CloudFront access logs"
}

output "tileserver_data_bucket_name" {
  value       = var.create_s3_tileserver_data_bucket ? join("", module.tileserver_data_bucket[*].name) : null
  description = "Name of S3 bucket used to store TileServer config data"
}

output "tileserver_data_bucket_arn" {
  value       = var.create_s3_tileserver_data_bucket ? join("", module.tileserver_data_bucket[*].arn) : null
  description = "ARN of S3 bucket used to store TileServer config data"
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

output "ecs_task_execution_iam_role_name" {
  value       = aws_iam_role.tileserver_ecs_task_execution.name
  description = "Name of ECS task execution IAM role"
}

output "ecs_task_execution_iam_role_arn" {
  value       = aws_iam_role.tileserver_ecs_task_execution.arn
  description = "ARN of ECS task execution IAM role"
}

output "ecs_task_iam_role_name" {
  value       = aws_iam_role.tileserver_ecs_task.name
  description = "Name of ECS task IAM role"
}

output "ecs_task_iam_role_arn" {
  value       = aws_iam_role.tileserver_ecs_task.arn
  description = "ARN of ECS task IAM role"
}

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.tileserver.name
  description = "Name of ECS cluster"
}

output "ecs_cluster_arn" {
  value       = aws_ecs_cluster.tileserver.arn
  description = "ARN of ECS cluster"
}

output "ecs_task_definition_family" {
  value       = aws_ecs_task_definition.tileserver_fargate.family
  description = "Family name of ECS task definition"
}

output "ecs_task_definition_arn" {
  value       = aws_ecs_task_definition.tileserver_fargate.arn
  description = "ARN of ECS task definition"
}

output "ecs_task_definition_arn_without_revision" {
  value       = aws_ecs_task_definition.tileserver_fargate.arn_without_revision
  description = "ARN of ECS task definition without revision"
}

output "ecs_task_definition_revision" {
  value       = aws_ecs_task_definition.tileserver_fargate.revision
  description = "Revision of ECS task definition"
}

output "ecs_service_security_group_id" {
  value       = aws_security_group.tileserver_ecs.id
  description = "ID of security group attached to ECS service"
}

output "ecs_service_name" {
  value       = aws_ecs_service.tileserver.name
  description = "Name of ECS service"
}

output "ecs_service_arn" {
  value       = aws_ecs_service.tileserver.id
  description = "ARN of ECS service"
}

output "efs_id" {
  value       = aws_efs_file_system.tileserver_data.id
  description = "ID of EFS file system"
}

output "efs_security_group_id" {
  value       = aws_security_group.tileserver_data_efs.id
  description = "ID of security group attached to EFS file system"
}

output "efs_tileserver_access_point_id" {
  value       = aws_efs_access_point.tileserver_data.id
  description = "ID of EFS access point for tileserver"
}

output "efs_tileserver_access_point_arn" {
  value       = aws_efs_access_point.tileserver_data.arn
  description = "ARN of EFS access point for tileserver"
}

output "efs_tileserver_nginx_tmp_access_point_id" {
  value       = aws_efs_access_point.tileserver_nginx_tmp.id
  description = "ID of EFS access point for nginx"
}

output "efs_tileserver_nginx_tmp_access_point_arn" {
  value       = aws_efs_access_point.tileserver_nginx_tmp.arn
  description = "ARN of EFS access point for nginx"
}

output "tileserver_domain_name" {
  value       = var.create_tileserver_dns_record ? join("", aws_route53_record.tileserver[*].name) : null
  description = "Domain name record created to expose TileServer"
}
