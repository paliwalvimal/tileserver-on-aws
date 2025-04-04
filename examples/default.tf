module "tileserver" {
  source = "github.com/paliwalvimal/tileserver-on-aws.git?ref=" # Always use `ref` to point module to a specific version or hash

  region                        = "eu-west-1"
  apigw_vpc_link_subnet_ids     = ["sub-xxxxxx", "sub-xxxxxx"]
  apigw_lambda_authz_subnet_ids = ["sub-xxxxxx", "sub-xxxxxx"]
  ecs_service_subnet_ids        = ["sub-xxxxxx", "sub-xxxxxx"]
  efs_subnet_ids                = ["sub-xxxxxx", "sub-xxxxxx"]
  tileserver_domain_name        = "tileserver.example.com"
  hosted_zone_id                = "Z000000000000000"
}
