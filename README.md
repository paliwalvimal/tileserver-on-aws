# terraform-base-template

This is a template repository that will serve as a starting point for all the new terraform modules

## Important changes:
- Replace `REPO_NAME` with the actual repository name in examples directory and .tf-header.md file
- Update module name in the examples directory
- Add title in the .tf-header.tf file

<!-- BEGIN_TF_DOCS -->
# Host TileServer on AWS

![License](https://img.shields.io/github/license/terrablocks/tileserver-on-aws?style=for-the-badge) ![Plan](https://img.shields.io/github/actions/workflow/status/terrablocks/tileserver-on-aws/tf-plan.yml?branch=main&label=Plan&style=for-the-badge) ![Checkov](https://img.shields.io/github/actions/workflow/status/terrablocks/tileserver-on-aws/checkov.yml?branch=main&label=Checkov&style=for-the-badge) ![Commit](https://img.shields.io/github/last-commit/terrablocks/tileserver-on-aws?style=for-the-badge) ![Release](https://img.shields.io/github/v/release/terrablocks/tileserver-on-aws?style=for-the-badge)

This terraform module manages the following services:
- CloudFront
- WAF
- CloudFront Function
- HTTP API Gateway
- Lambda Authorizer
- VPC Private Link
- Cloud Map
- ECS
- S3
- EFS

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.8.0 |
| archive | >= 2.4.0 |
| aws | >= 5.13.0 |
| awscc | >= 1.26.0 |
| random | >= 3.6.3 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| apigw_create_lambda_authz | Whether to create lambda authorizer for API gateway | `bool` | `true` | no |
| apigw_lambda_authz_subnet_ids | List of subnet IDs to use for creating Lambda authorizer | `list(string)` | `[]` | no |
| apigw_vpc_link_subnet_ids | List of subnet IDs to create ENIs for API Gateway to interact with ECS service | `list(string)` | n/a | yes |
| cloudfront_access_logs_destination_arn | ARN of destination to deliver the access logs to. Supported destinations are: S3, CloudWatch Logs, Kinesis Firehose. **Note:** Required only if `cloudfront_create_s3_bucket` is set to false | `string` | `""` | no |
| cloudfront_access_logs_format | Format of the logs that are sent to destination | `string` | `"json"` | no |
| cloudfront_cache_policy_id | ID of cache policy to associate with the default behaviour of cloudfront distribution. **Doc:** https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html | `string` | `"4135ea2d-6df8-44a3-9df3-4b5a84be39ad"` | no |
| cloudfront_create_s3_bucket | Whether to create S3 bucket for storing CloudFront access logs | `bool` | `true` | no |
| cloudfront_enable_access_logs | Enable v2 access logging for CloudFront distribution | `bool` | `true` | no |
| cloudfront_enable_waf | Whether to create a WAF with default configuration and attach it to the CloudFront distribution | `bool` | `true` | no |
| cloudfront_http_version | HTTP version to use for CloudFront distribution | `string` | `"http2"` | no |
| cloudfront_minimum_protocol_version | TLS protocol version to use for CloudFront distribution | `string` | `"TLSv1.2_2021"` | no |
| cloudfront_origin_request_policy_id | ID of response header policy to associate with the default behaviour of cloudfront distribution. **Doc:** https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-origin-request-policies.html | `string` | `"b689b0a8-53d0-40ab-baf2-68738e2966ac"` | no |
| cloudfront_price_class | Price class to use for CloudFront distribution | `string` | `"PriceClass_All"` | no |
| cloudfront_response_headers_policy_id | ID of response header policy to associate with the default behaviour of cloudfront distribution. **Doc:** https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-response-headers-policies.html | `string` | `null` | no |
| cloudfront_waf_id | ID of WAF to associate with the CloudFront distribution. **Note:** Required only if you want to associate self-managed WAF. Make sure to set `cloudfront_enable_waf` to false to use self-managed WAF | `string` | `null` | no |
| cors_origin_domain | Domain name to use for setting CORS `access-control-allow-origin` header | `string` | `"*"` | no |
| create_cloudfront_function | Whether to associate CloudFront Function to the distribution | `bool` | `true` | no |
| create_ssl_cert | Whether to create custom SSL certification for CloudFront distribution | `bool` | `true` | no |
| create_tileserver_dns_record | Whether to create DNS record for tileserver in Route53 | `bool` | `true` | no |
| cw_logs_kms_key_id | ID of KMS key to use for encrypting logs in CloudWatch | `string` | `null` | no |
| cw_logs_retention_days | Number of days to retain the API gateway logs for | `number` | `90` | no |
| env | Environment name: dev, qa, uat, staging, production | `string` | `"dev"` | no |
| hosted_zone_id | ID of hosted zone under which tileserver domain name needs to be registered. **Note:** Required only if either of `create_tileserver_dns_record` or `create_ssl_cert` is set to true | `string` | `""` | no |
| region | Region where the resources will be deployed | `string` | n/a | yes |
| tags | A map of key value pair to assign to resources | `map(string)` | `{}` | no |
| tileserver_acm_cert_arn | ARN of certificate stored in ACM to use for CloudFront distribution. **Note:** Only needed if `create_ssl_cert` is set to false | `string` | `""` | no |
| tileserver_domain_name | Domain name to associate with the CloudFront tileserver distribution | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| apigw_arn | ARN of the HTTP API Gateway |
| apigw_cwlg_arn | ARN of CloudWatch log group created to store API Gateway access logs |
| apigw_cwlg_name | Name of CloudWatch log group created to store API Gateway access logs |
| apigw_endpoint | Random URL assigned to the HTTP API Gateway by AWS |
| apigw_id | ID of the HTTP API Gateway |
| apigw_lambda_authz_arn | ARN of Lambda authorizer function created for API Gateway |
| apigw_lambda_authz_cwlg_arn | ARN of CloudWatch log group created to store Lambda authorizer logs |
| apigw_lambda_authz_cwlg_name | Name of CloudWatch log group created to store Lambda authorizer logs |
| apigw_lambda_authz_name | Name of Lambda authorizer function created for API Gateway |
| apigw_name | Name of the HTTP API Gateway |
| apigw_vpc_link_arn | ARN of VPC Private link created for HTTP API Gateway |
| apigw_vpc_link_id | ID of VPC Private link created for HTTP API Gateway |
| apigw_vpc_link_name | Name of VPC Private link created for HTTP API Gateway |
| cloud_map_svc_discovery_namespace_arn | ARN of the Cloud Map service discovery namespace |
| cloud_map_svc_discovery_namespace_id | ID of the Cloud Map service discovery namespace |
| cloud_map_svc_discovery_namespace_name | Name of the Cloud Map service discovery namespace |
| cloud_map_svc_discovery_svc_arn | ARN of the Cloud Map service discovery service |
| cloud_map_svc_discovery_svc_id | ID of the Cloud Map service discovery service |
| cloud_map_svc_discovery_svc_name | Name of the Cloud Map service discovery service |
| cloudfront_arn | ARN of CloudFront distribution |
| cloudfront_domain_name | Domain name assigned to CloudFront distribution |
| cloudfront_hosted_zone_id | Hosted zone ID of CloudFront distribution |
| cloudfront_id | ID of CloudFront distribution |
| s3_bucket_arn | ARN of S3 bucket used to store CloudFront access logs |
| s3_bucket_name | Name of S3 bucket used to store CloudFront access logs |
| tileserver_cf_authz_token_ssm_param_arn | ARN of SSM parameter used for storing authZ token shared between CloudFront and API Gateway |
| tileserver_cf_authz_token_ssm_param_name | Name of SSM parameter used for storing authZ token shared between CloudFront and API Gateway |
| waf_arn | ARN of WAF associated to CloudFront distribution |
| waf_id | ID of WAF associated to CloudFront distribution |
| waf_name | Name of WAF associated to CloudFront distribution |

<!-- END_TF_DOCS -->
