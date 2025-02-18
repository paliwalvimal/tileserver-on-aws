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
| aws | >= 5.13.0 |
| awscc | >= 1.26.0 |
| random | >= 3.6.3 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| env | Environment name: dev, qa, uat, staging, production | `string` | `"dev"` | no |
| hosted_zone_id | ID of hosted zone under which tileserver domain name needs to be registered | `string` | `""` | no |
| region | Region where the resources will be deployed | `string` | n/a | yes |
| tags | A map of key value pair to assign to resources | `map(string)` | `{}` | no |
| tileserver_domain_name | Domain name to associate with the CloudFront tileserver distribution | `string` | `""` | no |

## Outputs

No outputs.

<!-- END_TF_DOCS -->