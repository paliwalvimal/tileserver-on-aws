data "aws_region" "current" {}

data "aws_route53_zone" "tileserver" {
  count   = var.create_tileserver_dns_record || var.create_ssl_cert ? 1 : 0
  zone_id = var.hosted_zone_id
}

locals {
  prefix = var.env

  apigw_assume_role_policy = templatefile("${path.module}/iam-assume-role-policy.tftpl", {
    service_domain = "apigateway.amazonaws.com"
  })

  lambda_assume_role_policy = templatefile("${path.module}/iam-assume-role-policy.tftpl", {
    service_domain = "lambda.amazonaws.com"
  })

  ecs_tasks_assume_role_policy = templatefile("${path.module}/iam-assume-role-policy.tftpl", {
    service_domain = "ecs-tasks.amazonaws.com"
  })
}
