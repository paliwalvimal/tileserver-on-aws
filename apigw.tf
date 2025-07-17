locals {
  tileserver_lambda_authorizer_name = "tileserver-authorizer"
}

resource "aws_iam_role" "apigw_logs" {
  name                  = "${local.prefix}-apigw-cwlogs"
  force_detach_policies = true
  max_session_duration  = var.iam_role_max_session_duration
  assume_role_policy    = local.apigw_assume_role_policy
  tags                  = var.tags
}

resource "aws_iam_role_policy_attachment" "apigw_logs" {
  role       = aws_iam_role.apigw_logs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "current" {
  cloudwatch_role_arn = aws_iam_role.apigw_logs.arn
}

resource "aws_apigatewayv2_vpc_link" "tileserver" {
  name               = "${local.prefix}-tileserver-vpc-link"
  security_group_ids = [aws_security_group.tileserver_ecs.id]
  subnet_ids         = var.apigw_vpc_link_subnet_ids
  tags               = var.tags
}

resource "aws_iam_role" "tileserver_apigw_lambda_authorizer" {
  count                 = var.apigw_create_lambda_authz ? 1 : 0
  name                  = "${local.prefix}-${local.tileserver_lambda_authorizer_name}-lambda"
  force_detach_policies = true
  max_session_duration  = var.iam_role_max_session_duration
  assume_role_policy    = local.lambda_assume_role_policy
  tags                  = var.tags
}

resource "aws_iam_role_policy_attachment" "tileserver_apigw_lambda_authorizer_basic" {
  count      = var.apigw_create_lambda_authz ? 1 : 0
  role       = join("", aws_iam_role.tileserver_apigw_lambda_authorizer[*].name)
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "tileserver_apigw_lambda_authorizer_xray" {
  count      = var.apigw_create_lambda_authz && var.apigw_lambda_authz_tracing_mode == "Active" ? 1 : 0
  role       = join("", aws_iam_role.tileserver_apigw_lambda_authorizer[*].name)
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy" "tileserver_apigw_lambda_authorizer_ssm" {
  count = var.apigw_create_lambda_authz ? 1 : 0
  name  = "${local.prefix}-${local.tileserver_lambda_authorizer_name}-ssm"
  role  = join("", aws_iam_role.tileserver_apigw_lambda_authorizer[*].id)

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ssm:GetParameter"
        Resource = aws_ssm_parameter.tileserver_cf_authz_token.arn
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "tileserver_apigw_lambda_authorizer" {
  # checkov:skip=CKV_AWS_338: "Log retention period is user dependent"
  count             = var.apigw_create_lambda_authz ? 1 : 0
  name              = "/aws/lambda/${local.prefix}-${local.tileserver_lambda_authorizer_name}"
  retention_in_days = var.cw_logs_retention_days
  kms_key_id        = var.cw_logs_kms_key_id
  tags              = var.tags
}

data "archive_file" "tileserver_apigw_lambda_authorizer" {
  type        = "zip"
  source_file = "${path.module}/tileserver_apigw_lambda_authorizer.py"
  output_path = "${path.module}/.terraform/tileserver_apigw_lambda_authorizer.zip"
}

data "aws_subnet" "apigw_lambda_authz" {
  id = var.apigw_lambda_authz_subnet_ids[0]
}

resource "aws_security_group" "tileserver_apigw_lambda_authorizer" {
  # checkov:skip=CKV2_AWS_5: Security group is attached to Lambda function
  count                  = var.apigw_create_lambda_authz ? 1 : 0
  name                   = "${local.prefix}-${local.tileserver_lambda_authorizer_name}"
  vpc_id                 = data.aws_subnet.apigw_lambda_authz.vpc_id
  description            = "Security group for tileserver authorizer lambda function"
  revoke_rules_on_delete = true
  tags                   = var.tags
}

resource "aws_vpc_security_group_egress_rule" "tileserver_apigw_lambda_authorizer_https" {
  count             = var.apigw_create_lambda_authz ? 1 : 0
  security_group_id = join("", aws_security_group.tileserver_apigw_lambda_authorizer[*].id)
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Allow outbound HTTPS traffic"
  tags              = var.tags
}

resource "aws_lambda_function" "tileserver_apigw_authorizer" {
  # checkov:skip=CKV_AWS_50: X-ray tracing not required
  # checkov:skip=CKV_AWS_115: Concurrency not required
  # checkov:skip=CKV_AWS_116: DLQ not required
  # checkov:skip=CKV_AWS_173: Encryption for env vars not required
  # checkov:skip=CKV_AWS_272: Code signing not required
  count            = var.apigw_create_lambda_authz ? 1 : 0
  function_name    = "${local.prefix}-${local.tileserver_lambda_authorizer_name}"
  description      = "Custom authorizer function for tileserver api gateway"
  role             = join("", aws_iam_role.tileserver_apigw_lambda_authorizer[*].arn)
  filename         = data.archive_file.tileserver_apigw_lambda_authorizer.output_path
  source_code_hash = filebase64sha256(data.archive_file.tileserver_apigw_lambda_authorizer.output_path)
  handler          = "tileserver_apigw_lambda_authorizer.handler"
  timeout          = 5
  runtime          = "python3.11"
  memory_size      = 256
  architectures    = ["arm64"]
  tags             = var.tags

  environment {
    variables = {
      TILESERVER_AUTHZ_CF_TOKEN_CUSTOM_HEADER_NAME = local.tileserver_authz_cf_header_name
      TILESERVER_AUTHZ_CF_TOKEN_SSM_PARAM_NAME     = aws_ssm_parameter.tileserver_cf_authz_token.name
    }
  }

  vpc_config {
    subnet_ids         = var.apigw_lambda_authz_subnet_ids
    security_group_ids = aws_security_group.tileserver_apigw_lambda_authorizer[*].id
  }

  tracing_config {
    mode = var.apigw_lambda_authz_tracing_mode
  }

  depends_on = [
    aws_iam_role_policy_attachment.tileserver_apigw_lambda_authorizer_basic,

    # required to prevent lambda from automatically creating CloudWatch log group
    aws_cloudwatch_log_group.tileserver_apigw_lambda_authorizer
  ]
}

resource "aws_iam_role" "tileserver_apigw_lambda_authorizer_invoke" {
  count                 = var.apigw_create_lambda_authz ? 1 : 0
  name                  = "${local.prefix}-${local.tileserver_lambda_authorizer_name}-invoke"
  force_detach_policies = true
  max_session_duration  = var.iam_role_max_session_duration
  assume_role_policy    = local.apigw_assume_role_policy
  tags                  = var.tags
}

resource "aws_iam_role_policy" "tileserver_apigw_authorizer_invoke" {
  count = var.apigw_create_lambda_authz ? 1 : 0
  name  = "${local.prefix}-${local.tileserver_lambda_authorizer_name}-invoke"
  role  = join("", aws_iam_role.tileserver_apigw_lambda_authorizer_invoke[*].id)

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "lambda:InvokeFunction"
        Resource = aws_lambda_function.tileserver_apigw_authorizer[*].arn
      }
    ]
  })
}

# HTTP API Gateway
resource "aws_apigatewayv2_api" "tileserver" {
  name          = "${local.prefix}-tileserver"
  description   = "API Gateway for tileserver server"
  protocol_type = "HTTP"
  version       = "1.0"

  # AWS OpenAPI extensions: https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-swagger-extensions.html
  # OpenAPI doc: https://github.com/OAI/OpenAPI-Specification/blob/main/versions/3.1.0.md
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "${local.prefix}-tileserver"
      version = "1.0"
    }
    x-amazon-apigateway-binary-media-types = ["*/*"]
    tags                                   = [for k, v in var.tags : { name = k, x-amazon-apigateway-tag-value = v }]
    paths = {
      "/{path+}" : {
        "options" = {
          x-amazon-apigateway-integration = {
            payloadFormatVersion = "1.0"
            httpMethod           = "OPTIONS"
            type                 = "http_proxy"
            connectionType       = "VPC_LINK"
            connectionId         = aws_apigatewayv2_vpc_link.tileserver.id
            uri                  = aws_service_discovery_service.tileserver.arn
          }
        }
        "x-amazon-apigateway-any-method" = {
          security = var.apigw_create_lambda_authz ? [
            {
              (local.tileserver_lambda_authorizer_name) = []
            }
          ] : []
          x-amazon-apigateway-integration = {
            payloadFormatVersion = "1.0"
            httpMethod           = "ANY"
            type                 = "http_proxy"
            connectionType       = "VPC_LINK"
            connectionId         = aws_apigatewayv2_vpc_link.tileserver.id
            uri                  = aws_service_discovery_service.tileserver.arn
          }
        }
      }
    }
    components = var.apigw_create_lambda_authz ? {
      securitySchemes = {
        (local.tileserver_lambda_authorizer_name) = {
          type                         = "apiKey"
          name                         = "Authorization"
          in                           = "header"
          x-amazon-apigateway-authtype = "custom"
          x-amazon-apigateway-authorizer = {
            type                           = "request"
            authorizerUri                  = join("", aws_lambda_function.tileserver_apigw_authorizer[*].invoke_arn)
            authorizerCredentials          = join("", aws_iam_role.tileserver_apigw_lambda_authorizer_invoke[*].arn)
            authorizerPayloadFormatVersion = "2.0"
            enableSimpleResponses          = true
          }
        }
      }
    } : {}
  })

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "tileserver_api_logs" {
  # checkov:skip=CKV_AWS_338: "Log retention period is user dependent"
  name              = "/aws/apigw/${local.prefix}-tileserver"
  retention_in_days = var.cw_logs_retention_days
  kms_key_id        = var.cw_logs_kms_key_id
  tags              = var.tags
}

resource "aws_apigatewayv2_stage" "tileserver" {
  api_id      = aws_apigatewayv2_api.tileserver.id
  name        = "$default"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.tileserver_api_logs.arn
    format = jsonencode({
      authorizerError         = "$context.authorizer.error"
      authorizerPrincipalId   = "$context.authorizer.principalId"
      awsEndpointRequestId    = "$context.awsEndpointRequestId"
      awsEndpointRequestId2   = "$context.awsEndpointRequestId2"
      errorMsg                = "$context.error.message"
      requestId               = "$context.requestId"
      httpMethod              = "$context.httpMethod"
      sourceIp                = "$context.identity.sourceIp"
      userAgent               = "$context.identity.userAgent"
      integrationErrorMessage = "$context.integrationErrorMessage"
      integrationStatus       = "$context.integration.integrationStatus"
      status                  = "$context.integration.status"
      path                    = "$context.path"
      protocol                = "$context.protocol"
      requestTime             = "$context.requestTime"
      responseLatency         = "$context.responseLatency"
      methodStatus            = "$context.status"
    })
  }

  tags = var.tags
}
