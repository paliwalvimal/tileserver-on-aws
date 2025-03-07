data "aws_kms_key" "s3" {
  key_id = var.s3_kms_key
}

module "tileserver_cf_access_logs_bucket" {
  source = "github.com/terrablocks/aws-s3-bucket.git?ref=cace8fe" # v1.1.1

  count                 = var.create_cloudfront_logs_bucket ? 1 : 0
  name                  = "${local.prefix}-tileserver-cf-access-logs"
  force_destroy         = true
  kms_key               = var.s3_kms_key == "alias/aws/s3" ? "alias/aws/s3" : data.aws_kms_key.s3.arn
  apply_ssl_deny_policy = false
  tags                  = var.tags
}

resource "aws_s3_bucket_policy" "tileserver_cf_access_logs" {
  count  = var.create_cloudfront_logs_bucket ? 1 : 0
  bucket = join("", module.tileserver_cf_access_logs_bucket[*].name)

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowSSLRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          join("", module.tileserver_cf_access_logs_bucket[*].arn),
          "${join("", module.tileserver_cf_access_logs_bucket[*].arn)}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
          NumericLessThan = {
            "s3:TlsVersion" = "1.2"
          }
        }
      },
      {
        Sid    = "AWSLogDeliveryWrite"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action = [
          "s3:PutObject"
        ]
        Resource = [
          "${join("", module.tileserver_cf_access_logs_bucket[*].arn)}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
            "s3:x-amz-acl"      = "bucket-owner-full-control"
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:logs:us-east-1:${local.account_id}:delivery-source:${join("", awscc_logs_delivery_source.tileserver_cf[*].name)}"
          }
        }
      }
    ]
  })
}

module "tileserver_data_bucket" {
  source = "github.com/terrablocks/aws-s3-bucket.git?ref=cace8fe" # v1.1.1

  count                 = var.create_s3_tileserver_data_bucket ? 1 : 0
  name                  = "${local.prefix}-tileserver-data"
  force_destroy         = true
  kms_key               = var.s3_kms_key == "alias/aws/s3" ? "alias/aws/s3" : data.aws_kms_key.s3.arn
  apply_ssl_deny_policy = var.tileserver_data_bucket_apply_ssl_deny_policy
  tags                  = var.tags
}
