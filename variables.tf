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
  default     = "http2"
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
  description = "TLS protocol version to use for CloudFront distribution"
}

variable "cloudfront_enable_access_logs" {
  type        = bool
  default     = true
  description = "Enable v2 access logging for CloudFront distribution"
}

variable "cloudfront_create_s3_bucket" {
  type        = bool
  default     = true
  description = "Whether to create S3 bucket for storing CloudFront access logs"
}

variable "cloudfront_access_logs_destination_arn" {
  type        = string
  default     = ""
  description = "ARN of destination to deliver the access logs to. Supported destinations are: S3, CloudWatch Logs, Kinesis Firehose. **Note:** Required only if `cloudfront_create_s3_bucket` is set to false"
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
  description = "ID of WAF to associate with the CloudFront distribution. **Note:** Required only if you want to associate self-managed WAF. Make sure to set `cloudfront_enable_waf` to false to use self-managed WAF"
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

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of key value pair to assign to resources"
}
