data "aws_kms_key" "s3" {
  key_id = var.s3_kms_key
}

module "tileserver_cf_access_logs_bucket" {
  source = "github.com/terrablocks/aws-s3-bucket.git?ref=cace8fe" # v1.1.1

  count                 = var.cloudfront_create_s3_bucket ? 1 : 0
  name                  = "${local.prefix}-tileserver-cf-access-logs"
  force_destroy         = true
  kms_key               = var.s3_kms_key == "alias/aws/s3" ? "alias/aws/s3" : data.aws_kms_key.s3.arn
  apply_ssl_deny_policy = var.s3_tileserver_cf_access_logs_bucket_apply_ssl_deny_policy
  tags                  = var.tags
}
