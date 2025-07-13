resource "aws_cloudwatch_log_group" "tileserver_ecs_logs" {
  # checkov:skip=CKV_AWS_338: "Ensure CloudWatch log groups retains logs for at least 1 year"
  name              = "/ecs/${aws_ecs_cluster.tileserver.name}"
  retention_in_days = var.cw_logs_retention_days
  kms_key_id        = var.cw_logs_kms_key_id
  tags              = var.tags
}

# IAM role for tileserver ECS task execution
resource "aws_iam_role" "tileserver_ecs_task_execution" {
  name                  = "${local.prefix}-tileserver-ecs-task-execution"
  force_detach_policies = true
  max_session_duration  = var.iam_role_max_session_duration
  assume_role_policy    = local.ecs_tasks_assume_role_policy
  tags                  = var.tags
}

resource "aws_iam_role_policy" "tileserver_ecs_task_execution" {
  # checkov:skip=CKV_AWS_290: "Write access required to allow writing to CloudWatch logs"
  # checkov:skip=CKV_AWS_355: "'*' as a statement's resource is required to allow writing to CloudWatch logs"
  name = "${local.prefix}-tileserver-ecs-task-execution"
  role = aws_iam_role.tileserver_ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.tileserver_ecs_logs.arn}:*"
      }
    ]
  })
}

# IAM role for tileserver ECS task role
resource "aws_iam_role" "tileserver_ecs_task" {
  name                  = "${local.prefix}-tileserver-ecs-task"
  force_detach_policies = true
  max_session_duration  = var.iam_role_max_session_duration

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:ecs:${var.region}:${local.account_id}:*"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "tileserver_ecs_task_s3" {
  count = var.create_s3_tileserver_data_bucket ? 1 : 0
  name  = "${local.prefix}-tileserver-ecs-task-s3"
  role  = aws_iam_role.tileserver_ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject*"
        ]
        Resource = [
          join("", module.tileserver_data_bucket[*].arn),
          "${join("", module.tileserver_data_bucket[*].arn)}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "tileserver_ecs_task_s3_kms" {
  count = var.create_s3_tileserver_data_bucket && var.s3_kms_key != "alias/aws/s3" ? 1 : 0
  name  = "${local.prefix}-tileserver-ecs-task-s3-kms"
  role  = aws_iam_role.tileserver_ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey*",
          "kms:Decrypt"
        ]
        Resource = [
          data.aws_kms_key.s3.arn
        ]
      }
    ]
  })
}

resource "aws_ecs_cluster" "tileserver" {
  # checkov:skip=CKV_AWS_65: Container insights not required
  name = "${local.prefix}-tileserver"

  dynamic "setting" {
    for_each = var.ecs_enable_container_insights ? [0] : []
    content {
      name  = "containerInsights"
      value = "enhanced"
    }
  }

  tags = merge(
    var.ecs_enable_guard_duty_monitoring ? {
      guardDutyRuntimeMonitoringManaged = "true"
    } : {},
  var.tags)
}

locals {
  tileserver_container_port = 8081

  nginx_config_base64 = base64encode(templatefile("${path.module}/nginx.conf.tpl", {
    nginx_port                = var.ecs_service_port
    tileserver_container_port = local.tileserver_container_port
    tileserver_hostname       = var.tileserver_domain_name
  }))
}

resource "aws_ecs_task_definition" "tileserver_fargate" {
  family                   = "${local.prefix}-tileserver-fargate"
  requires_compatibilities = ["FARGATE"]

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  execution_role_arn = aws_iam_role.tileserver_ecs_task_execution.arn
  task_role_arn      = aws_iam_role.tileserver_ecs_task.arn
  network_mode       = "awsvpc"
  cpu                = var.ecs_service_cpu
  memory             = var.ecs_service_memory

  container_definitions = jsonencode(flatten([
    [{
      name         = "nginx-init",
      image        = var.ecs_service_nginx_init_container_image,
      cpu          = 128,
      memory       = 256,
      portMappings = [],
      essential    = false,
      command = [
        "sh",
        "-c",
        "echo ${local.nginx_config_base64} | base64 -d | tee /etc/nginx/nginx.conf"
      ],
      environment = [],
      mountPoints = [
        {
          sourceVolume  = "nginx-conf",
          containerPath = "/etc/nginx",
          readOnly      = false
        }
      ],
      volumesFrom            = [],
      privileged             = false,
      readonlyRootFilesystem = true,
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-region        = var.region,
          awslogs-group         = aws_cloudwatch_log_group.tileserver_ecs_logs.name,
          awslogs-stream-prefix = "nginx-init"
        }
      },
      linuxParameters = {
        capabilities = {
          drop = ["ALL"]
          add  = []
        }
      },
      systemControls = []
    }],
    [{
      name   = "nginx",
      image  = var.ecs_service_nginx_container_image,
      cpu    = var.ecs_service_nginx_container_cpu,
      memory = var.ecs_service_nginx_container_memory,
      portMappings = [
        {
          containerPort = var.ecs_service_port,
          hostPort      = var.ecs_service_port,
          protocol      = "tcp"
        }
      ],
      essential   = true,
      environment = [],
      mountPoints = [
        {
          sourceVolume  = "nginx-conf",
          containerPath = "/etc/nginx",
          readOnly      = true
        },
        {
          sourceVolume  = "tileserver-nginx-tmp",
          containerPath = local.tileserver_nginx_tmp_mount_path,
          readOnly      = false
        }
      ],
      volumesFrom = [],
      dependsOn = [
        {
          containerName = "nginx-init",
          condition     = "SUCCESS"
        },
        {
          containerName = "tileserver",
          condition     = "START"
        }
      ],
      privileged             = false,
      readonlyRootFilesystem = true,
      user                   = tostring(local.tileserver_nginx_tmp_efs_uid),
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-region        = var.region,
          awslogs-group         = aws_cloudwatch_log_group.tileserver_ecs_logs.name,
          awslogs-stream-prefix = "nginx"
        }
      },
      healthCheck = {
        command = [
          "CMD-SHELL",
          "wget --spider http://localhost:${var.ecs_service_port}/ping"
        ],
        interval    = 30,
        timeout     = 2,
        retries     = 3,
        startPeriod = 2
      },
      linuxParameters = {
        capabilities = {
          drop = ["ALL"]
          add  = []
        }
      },
      systemControls = []
    }],
    var.create_s3_tileserver_data_bucket ? [{
      name         = "tileserver-init",
      image        = var.ecs_service_tileserver_init_container_image,
      cpu          = 128,
      memory       = 256,
      portMappings = [],
      essential    = false,
      command = [
        "s3",
        "sync",
        "--delete",
        "s3://${join("", module.tileserver_data_bucket[*].name)}/",
        "/data"
      ],
      environment = [],
      mountPoints = [
        {
          sourceVolume  = "tileserver-data",
          containerPath = local.tileserver_data_mount_path,
          readOnly      = false
        }
      ],
      volumesFrom            = [],
      privileged             = false,
      user                   = tostring(local.tileserver_data_efs_uid),
      readonlyRootFilesystem = true,
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-region        = var.region,
          awslogs-group         = aws_cloudwatch_log_group.tileserver_ecs_logs.name,
          awslogs-stream-prefix = "tileserver-init"
        }
      },
      linuxParameters = {
        capabilities = {
          drop = ["ALL"]
          add  = []
        }
      },
      systemControls = []
    }] : [],
    [{
      name   = "tileserver",
      image  = var.ecs_service_tileserver_container_image,
      cpu    = var.ecs_service_tileserver_container_cpu,
      memory = var.ecs_service_tileserver_container_memory,
      portMappings = [
        {
          containerPort = local.tileserver_container_port,
          hostPort      = local.tileserver_container_port,
          protocol      = "tcp"
        }
      ],
      essential = true,
      command = [
        "--port",
        tostring(local.tileserver_container_port)
      ],
      environment = [],
      mountPoints = [
        {
          sourceVolume  = "tileserver-data",
          containerPath = local.tileserver_data_mount_path,
          # readonly is set to false because during the initial run if mbtiles is not present,
          # tileserver will download the default mbtiles file
          readOnly = false
        }
      ],
      volumesFrom = [],
      dependsOn = var.create_s3_tileserver_data_bucket ? [
        {
          containerName = "tileserver-init",
          condition     = "SUCCESS"
        }
      ] : [],
      privileged             = false,
      readonlyRootFilesystem = true,
      user                   = tostring(local.tileserver_data_efs_uid),
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-region        = var.region,
          awslogs-group         = aws_cloudwatch_log_group.tileserver_ecs_logs.name,
          awslogs-stream-prefix = "tileserver"
        }
      },
      healthCheck = {
        command = [
          "CMD-SHELL",
          "node /usr/src/app/src/healthcheck.js"
        ],
        interval    = 30,
        timeout     = 2,
        retries     = 3,
        startPeriod = 2
      },
      linuxParameters = {
        capabilities = {
          drop = ["ALL"]
          add  = []
        }
      },
      systemControls = []
    }]
  ]))

  volume {
    name = "tileserver-data"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.tileserver_data.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.tileserver_data.id
        iam             = "ENABLED"
      }
    }
  }

  volume {
    name = "tileserver-nginx-tmp"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.tileserver_data.id
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = aws_efs_access_point.tileserver_nginx_tmp.id
        iam             = "ENABLED"
      }
    }
  }

  volume {
    name = "nginx-conf"
  }

  tags = var.tags
}

data "aws_subnet" "tileserver_ecs_service" {
  id = var.ecs_service_subnet_ids[0]
}

resource "aws_security_group" "tileserver_ecs" {
  name        = "${local.prefix}-tileserver-ecs-sg"
  description = "Security group for tileserver ECS service"
  vpc_id      = data.aws_subnet.tileserver_ecs_service.vpc_id
  tags        = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "tileserver_ecs_self" {
  security_group_id            = aws_security_group.tileserver_ecs.id
  from_port                    = var.ecs_service_port
  to_port                      = var.ecs_service_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.tileserver_ecs.id
  description                  = "Allow 8080 from resources within the same sg"
  tags                         = var.tags
}

resource "aws_vpc_security_group_egress_rule" "tileserver_ecs_all" {
  security_group_id = aws_security_group.tileserver_ecs.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all outbound connections"
  tags              = var.tags
}

resource "aws_ecs_service" "tileserver" {
  name                          = "${local.prefix}-tileserver"
  cluster                       = aws_ecs_cluster.tileserver.arn
  task_definition               = aws_ecs_task_definition.tileserver_fargate.arn
  desired_count                 = var.ecs_service_min_replicas
  launch_type                   = "FARGATE"
  availability_zone_rebalancing = "ENABLED"
  force_delete                  = true
  wait_for_steady_state         = true

  network_configuration {
    subnets          = var.ecs_service_subnet_ids
    security_groups  = [aws_security_group.tileserver_ecs.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.tileserver.arn
    port         = var.ecs_service_port
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  tags = var.tags

  depends_on = [
    aws_efs_mount_target.tileserver_data
  ]

  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }
}

resource "aws_appautoscaling_target" "tileserver" {
  max_capacity       = var.ecs_service_max_replicas
  min_capacity       = var.ecs_service_min_replicas
  resource_id        = "service/${aws_ecs_cluster.tileserver.name}/${aws_ecs_service.tileserver.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  tags               = var.tags
}

resource "aws_appautoscaling_policy" "tileserver" {
  name               = "${local.prefix}-tileserver"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.tileserver.resource_id
  scalable_dimension = aws_appautoscaling_target.tileserver.scalable_dimension
  service_namespace  = aws_appautoscaling_target.tileserver.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 60
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}
