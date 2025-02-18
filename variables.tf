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

variable "hosted_zone_id" {
  type        = string
  default     = ""
  description = "ID of hosted zone under which tileserver domain name needs to be registered"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of key value pair to assign to resources"
}
