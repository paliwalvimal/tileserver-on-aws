module "tileserver_cf_access_logs_bucket" {
  source = "github.com/terrablocks/aws-s3-bucket.git?ref=f07b806"

  name          = "${local.prefix}-tileserver-cf-access-logs"
  force_destroy = true

  lifecycle_rules = [
    {
      enabled                                = true
      id                                     = "full-bucket"
      abort_incomplete_multipart_upload_days = 1

      expiration = {
        days = 90
      }

      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        }
      ]
    }
  ]

  tags = var.tags
}
