data "aws_subnet" "apigw_vpc_link" {
  id = var.apigw_vpc_link_subnet_ids[0]
}

resource "aws_service_discovery_private_dns_namespace" "tileserver" {
  name        = "${local.prefix}-tileserver"
  description = "Namespace for tileserver service"
  vpc         = data.aws_subnet.apigw_vpc_link.vpc_id
  tags        = var.tags
}

resource "aws_service_discovery_service" "tileserver" {
  name          = "${local.prefix}-tileserver"
  force_destroy = true
  namespace_id  = aws_service_discovery_private_dns_namespace.tileserver.id

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.tileserver.id
    dns_records {
      ttl  = 60
      type = "SRV"
    }
    routing_policy = "MULTIVALUE"
  }

  tags = var.tags
}
