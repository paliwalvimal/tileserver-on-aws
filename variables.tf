variable "region" {
  type        = string
  description = "Region where the resources will be deployed"
}

variable "env" {
  type        = string
  default     = "dev"
  description = "Environment name: dev, qa, uat, staging, production"
}

variable "create_cloudfront_function" {
  type        = bool
  default     = true
  description = "Whether to associate CloudFront Function to the distribution"
}

variable "cors_origin_domain" {
  type        = string
  default     = "*"
  description = "Domain name to use for setting CORS `access-control-allow-origin` header"
}

variable "cloudfront_price_class" {
  type        = string
  default     = "PriceClass_All"
  description = "Price class to use for CloudFront distribution"
}

variable "cloudfront_http_version" {
  type        = string
  default     = "http2and3"
  description = "HTTP version to use for CloudFront distribution"
}

variable "cloudfront_cache_policy_id" {
  type        = string
  default     = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # Managed-CachingDisabled
  description = "ID of cache policy to associate with the default behaviour of cloudfront distribution. **Doc:** https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html"
}

variable "cloudfront_origin_request_policy_id" {
  type        = string
  default     = "b689b0a8-53d0-40ab-baf2-68738e2966ac" # Managed-AllViewerExceptHostHeader
  description = "ID of response header policy to associate with the default behaviour of cloudfront distribution. **Doc:** https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-origin-request-policies.html"
}

variable "cloudfront_response_headers_policy_id" {
  type        = string
  default     = null
  description = "ID of response header policy to associate with the default behaviour of cloudfront distribution. **Doc:** https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-response-headers-policies.html"
}

variable "cloudfront_minimum_protocol_version" {
  type        = string
  default     = "TLSv1.2_2021"
  description = "TLS protocol version to use for CloudFront distribution. For all supported versions, refer to [AWS doc](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/secure-connections-supported-viewer-protocols-ciphers.html)"
}

variable "cloudfront_enable_access_logs" {
  type        = bool
  default     = true
  description = "Enable v2 access logging for CloudFront distribution"
}

variable "create_cloudfront_logs_bucket" {
  type        = bool
  default     = true
  description = "Whether to create S3 bucket for storing CloudFront access logs"
}

variable "cloudfront_access_logs_destination_arn" {
  type        = string
  default     = ""
  description = "ARN of destination to deliver the access logs to. Supported destinations are: S3, CloudWatch Logs, Kinesis Firehose. **Note:** Required only if `create_cloudfront_logs_bucket` is set to false"
}

variable "cloudfront_access_logs_format" {
  type        = string
  default     = "json"
  description = "Format of the logs that are sent to destination"
}

variable "cloudfront_enable_waf" {
  type        = bool
  default     = true
  description = "Whether to create a WAF with default configuration and attach it to the CloudFront distribution"
}

variable "cloudfront_waf_id" {
  type        = string
  default     = null
  description = "ID of WAF to associate with the CloudFront distribution. **Note:** Required only if you want to associate a self-managed WAF. Make sure to set `cloudfront_enable_waf` to false to use a self-managed WAF"
}

variable "tileserver_domain_name" {
  type        = string
  default     = ""
  description = "Domain name to associate with the CloudFront tileserver distribution"
}

variable "create_tileserver_dns_record" {
  type        = bool
  default     = true
  description = "Whether to create DNS record for tileserver in Route53"
}

variable "create_ssl_cert" {
  type        = bool
  default     = true
  description = "Whether to create custom SSL certification for CloudFront distribution"
}

variable "hosted_zone_id" {
  type        = string
  default     = ""
  description = "ID of hosted zone under which tileserver domain name needs to be registered. **Note:** Required only if either of `create_tileserver_dns_record` or `create_ssl_cert` is set to true"
}

variable "tileserver_acm_cert_arn" {
  type        = string
  default     = ""
  description = "ARN of certificate stored in ACM to use for CloudFront distribution. **Note:** Only needed if `create_ssl_cert` is set to false"
}

variable "cw_logs_retention_days" {
  type        = number
  default     = 90
  description = "Number of days to retain the API gateway logs for"
}

variable "cw_logs_kms_key_id" {
  type        = string
  default     = null
  description = "ID of KMS key to use for encrypting logs in CloudWatch"
}

variable "apigw_vpc_link_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to create ENIs for API Gateway to interact with ECS service"
}

variable "apigw_create_lambda_authz" {
  type        = bool
  default     = true
  description = "Whether to create lambda authorizer for API gateway"
}

variable "apigw_lambda_authz_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to use for creating Lambda authorizer"
}

variable "apigw_lambda_authz_tracing_mode" {
  type        = string
  default     = "Active"
  description = "Tracing mode to use for Lambda authorizer. Valid values: PassThrough, Active"
}

variable "s3_kms_key" {
  type        = string
  default     = "alias/aws/s3"
  description = "ARN/Alias/ID of KMS key to use for encrypting objects stored in S3 bucket"
}

variable "ecs_enable_container_insights" {
  type        = bool
  default     = true
  description = "Whether to enable container insights for ECS cluster"
}

variable "ecs_enable_guard_duty_monitoring" {
  type        = bool
  default     = true
  description = "Whether to enable guard duty monitoring for ECS cluster"
}

variable "create_s3_tileserver_data_bucket" {
  type        = bool
  default     = false
  description = "Whether to create S3 bucket for storing tileserver data like config files, mbtiles, etc"
}

variable "tileserver_data_bucket_apply_ssl_deny_policy" {
  type        = bool
  default     = true
  description = "Apply the [default SSL deny policy](https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies.html#example-bucket-policies-HTTP-HTTPS) to the S3 bucket. **Note:** Set this to false if you want to attach your own policy"
}

variable "efs_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to create mount points for EFS volume"
}

variable "ecs_service_cpu" {
  type        = number
  default     = 1024
  description = "Hard limit of CPU units for the ECS service. This should be enough to run both nginx and TileServer containers. Valid values for CPU units: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size"
}

variable "ecs_service_memory" {
  type        = number
  default     = 2048
  description = "Hard limit of memory for the ECS service. This should be enough to run both nginx and TileServer containers. Valid values for memory: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size"
}

variable "ecs_service_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to create ENIs for TileServer ECS service"
}

variable "ecs_service_port" {
  type        = number
  default     = 8080
  description = "Port to expose for TileServer container"
}

variable "ecs_service_min_replicas" {
  type        = number
  default     = 1
  description = "Minimum number of replicas to run for ECS service"
}

variable "ecs_service_max_replicas" {
  type        = number
  default     = 2
  description = "Maximum number of replicas to run for ECS service"
}

variable "ecs_service_nginx_init_container_image" {
  type        = string
  default     = "mirror.gcr.io/alpine@sha256:4bcff63911fcb4448bd4fdacec207030997caf25e9bea4045fa6c8c44de311d1" # v3.22.1
  description = "Image to use for nginx init container"
}

variable "ecs_service_nginx_container_image" {
  type        = string
  default     = "mirror.gcr.io/nginxinc/nginx-unprivileged@sha256:705969795f0ccff6b15aefac9028641cbb71f48b175491eebb995b77f1e75ec7" # alpine3.22-perl
  description = "Image to use for nginx container"
}

variable "ecs_service_nginx_container_cpu" {
  type        = number
  default     = 256
  description = "Number of CPU units to provision for nginx container"
}

variable "ecs_service_nginx_container_memory" {
  type        = number
  default     = 512
  description = "Amount (in MiB) of memory to provision for nginx container"
}

variable "ecs_service_tileserver_init_container_image" {
  type        = string
  default     = "mirror.gcr.io/amazon/aws-cli@sha256:5ee59dfb0f032cdc00ef175940be5cc1c3dd4621ccc27fb3cfcfd43d5b7d90e9" # v2.27.57
  description = "Image to use for TileServer init container"
}

variable "ecs_service_tileserver_container_image" {
  type        = string
  default     = "mirror.gcr.io/maptiler/tileserver-gl-light@sha256:a7ac7824ecb497c8971dd9c284416e96cd1c7e21e86a693fc82a37912670cd84" # v5.3.1
  description = "Image to use for TileServer container"
}

variable "ecs_service_tileserver_container_cpu" {
  type        = number
  default     = 256
  description = "Number of CPU units to provision for TileServer container"
}

variable "ecs_service_tileserver_container_memory" {
  type        = number
  default     = 512
  description = "Amount (in MiB) of memory to provision for TileServer container"
}

variable "iam_role_max_session_duration" {
  type        = number
  default     = null
  description = "Maximum session duration for IAM role. If not provided, the default value of 3600 seconds (1 hour) is applied by AWS"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of key value pair to assign to resources"
}
