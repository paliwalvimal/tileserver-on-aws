resource "aws_cloudwatch_log_group" "tileserver_ecs_logs" {
  # checkov:skip=CKV_AWS_338: "Ensure CloudWatch log groups retains logs for at least 1 year"
  name              = "/ecs/${aws_ecs_cluster.tileserver.name}"
  retention_in_days = var.cw_logs_retention_days
  kms_key_id        = var.cw_logs_kms_key_id
  tags              = var.tags
}

# IAM role for tileserver ECS task execution
resource "aws_iam_role" "tileserver_ecs_task_execution" {
  name                 = "${local.prefix}-tileserver-ecs-task-execution"
  max_session_duration = 21600 # 6 hours
  assume_role_policy   = local.ecs_tasks_assume_role_policy
  tags                 = var.tags
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
  name                 = "${local.prefix}-tileserver-ecs-task"
  max_session_duration = 21600 # 6 hours

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
            "aws:SourceArn" = "arn:aws:ecs:${var.region}:${data.aws_region.current.name}:*"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# resource "aws_iam_role_policy" "tileserver_ecs_task" {
#   name = "${local.prefix}-tileserver-ecs-task"
#   role = aws_iam_role.tileserver_ecs_task.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:ListBucket",
#           "s3:GetObject*"
#         ]
#         Resource = [
#           module.tileserver_files_bucket.arn,
#           "${module.tileserver_files_bucket.arn}/*"
#         ]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "kms:GenerateDataKey*",
#           "kms:Decrypt"
#         ]
#         Resource = [
#           module.s3_kms.key_arn
#         ]
#       }
#     ]
#   })
# }

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
