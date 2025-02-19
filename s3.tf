module "tileserver_cf_access_logs_bucket" {
  source = "github.com/terrablocks/aws-s3-bucket.git?ref=f07b806"

  count         = var.cloudfront_create_s3_bucket ? 1 : 0
  name          = "${local.prefix}-tileserver-cf-access-logs"
  force_destroy = true
  tags          = var.tags
}
