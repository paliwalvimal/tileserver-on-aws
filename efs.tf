resource "aws_efs_file_system" "tileserver_data" {
  # checkov:skip=CKV_AWS_184: CMK encryption can be enabled by user
  # checkov:skip=CKV2_AWS_18: Backup can be enabled by user
  creation_token   = "${local.prefix}-tileserver-data"
  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"

  tags = merge(
    {
      Name = "${local.prefix}-tileserver-data"
    },
  var.tags)
}

data "aws_subnet" "tileserver_efs" {
  id = var.efs_subnet_ids[0]
}

resource "aws_security_group" "tileserver_data_efs" {
  name        = "${local.prefix}-tileserver-data-efs"
  description = "Security group for tileserver efs volume"
  vpc_id      = data.aws_subnet.tileserver_efs.vpc_id
  tags        = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "tileserver_data_efs_nfs_ecs" {
  security_group_id            = aws_security_group.tileserver_data_efs.id
  from_port                    = 2049
  to_port                      = 2049
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.tileserver_ecs.id
  description                  = "Allow connections from tileserver ecs service"
  tags                         = var.tags
}

resource "aws_efs_mount_target" "tileserver_data" {
  for_each        = toset(var.efs_subnet_ids)
  file_system_id  = aws_efs_file_system.tileserver_data.id
  subnet_id       = each.value
  security_groups = [aws_security_group.tileserver_data_efs.id]
}

locals {
  tileserver_data_efs_uid         = 1001
  tileserver_data_mount_path      = "/data"
  tileserver_nginx_tmp_efs_uid    = 101
  tileserver_nginx_tmp_mount_path = "/tmp/nginx"
}

resource "aws_efs_access_point" "tileserver_data" {
  file_system_id = aws_efs_file_system.tileserver_data.id

  posix_user {
    uid = local.tileserver_data_efs_uid
    gid = local.tileserver_data_efs_uid
  }

  root_directory {
    creation_info {
      owner_uid   = local.tileserver_data_efs_uid
      owner_gid   = local.tileserver_data_efs_uid
      permissions = "755"
    }
    path = local.tileserver_data_mount_path
  }

  tags = var.tags
}

resource "aws_efs_access_point" "tileserver_nginx_tmp" {
  file_system_id = aws_efs_file_system.tileserver_data.id

  posix_user {
    uid = local.tileserver_nginx_tmp_efs_uid
    gid = local.tileserver_nginx_tmp_efs_uid
  }

  root_directory {
    creation_info {
      owner_uid   = local.tileserver_nginx_tmp_efs_uid
      owner_gid   = local.tileserver_nginx_tmp_efs_uid
      permissions = "755"
    }
    path = local.tileserver_nginx_tmp_mount_path
  }

  tags = var.tags
}

resource "aws_efs_file_system_policy" "tileserver_data" {
  file_system_id = aws_efs_file_system.tileserver_data.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyUnsecureTransport"
        Effect = "Deny"
        Principal = {
          AWS = "*"
        }
        Action   = "*"
        Resource = aws_efs_file_system.tileserver_data.arn
        Condition = {
          Bool = {
            "aws:SecureTransport" = false
          }
        }
      },
      {
        Sid    = "AllowAccessTotileserverEcsTaskRole"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.tileserver_ecs_task.arn
        }
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite"
        ]
        Resource = aws_efs_file_system.tileserver_data.arn
        Condition = {
          StringEquals = {
            "elasticfilesystem:AccessPointArn" = [
              aws_efs_access_point.tileserver_data.arn,
              aws_efs_access_point.tileserver_nginx_tmp.arn
            ]
          }
        }
      }
    ]
  })
}
