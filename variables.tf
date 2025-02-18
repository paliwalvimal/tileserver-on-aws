variable "region" {
  type        = string
  description = "Region where the resources will be deployed"
}

variable "env" {
  type        = string
  default     = "dev"
  description = "Environment name: dev, qa, uat, staging, production"
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
  description = "ID of hosted zone under which tileserver domain name needs to be registered. Required only if either of `create_tileserver_dns_record` or `create_ssl_cert` is set to true"
}

variable "tileserver_acm_cert_arn" {
  type        = string
  default     = ""
  description = "ARN of certificate stored in ACM to use for CloudFront distribution. Only needed if `create_ssl_cert` is set to false"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of key value pair to assign to resources"
}
