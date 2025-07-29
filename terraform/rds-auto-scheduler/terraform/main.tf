# EventBridge Rules
resource "aws_cloudwatch_event_rule" "rds_start" {
  name                = "rds-auto-scheduler-start"
  description         = "Start RDS instances based on schedule"
  schedule_expression = var.start_schedule
  state               = "ENABLED"
}

resource "aws_cloudwatch_event_rule" "rds_stop" {
  name                = "rds-auto-scheduler-stop"
  description         = "Stop RDS instances based on schedule"
  schedule_expression = var.stop_schedule
  state               = "ENABLED"
}

# EventBridge Targets
resource "aws_cloudwatch_event_target" "rds_start_target" {
  rule      = aws_cloudwatch_event_rule.rds_start.name
  target_id = "RDSStartTarget"
  arn       = aws_lambda_function.rds_auto_scheduler.arn
  input     = jsonencode({ action = "start" })
}

resource "aws_cloudwatch_event_target" "rds_stop_target" {
  rule      = aws_cloudwatch_event_rule.rds_stop.name
  target_id = "RDSStopTarget"
  arn       = aws_lambda_function.rds_auto_scheduler.arn
  input     = jsonencode({ action = "stop" })
}

# Get current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "rds-auto-scheduler-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "rds-auto-scheduler-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "logs:CreateLogGroup"
        Resource = "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.rds_auto_scheduler.function_name}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBClusters",
          "rds:DescribeDBInstances",
          "rds:ListTagsForResource",
          "rds:StartDBCluster",
          "rds:StartDBInstance",
          "rds:StopDBCluster",
          "rds:StopDBInstance",
        ]
        Resource = "*"
      }
    ]
  })
}

# Build Lambda package if it doesn't exist
resource "null_resource" "build_lambda" {
  triggers = {
    lambda_code  = filemd5("../src/lambda_function.py")
    requirements = filemd5("../src/requirements.txt")
  }

  provisioner "local-exec" {
    command = "../build_lambda.sh"
  }
}

# Lambda deployment package (created by build script)
data "local_file" "lambda_zip" {
  filename   = "rds_auto_scheduler.zip"
  depends_on = [null_resource.build_lambda]
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "rds_auto_scheduler" {
  name              = "/aws/lambda/rds-auto-scheduler"
  retention_in_days = 7
}

# Lambda Function
resource "aws_lambda_function" "rds_auto_scheduler" {
  filename         = "rds_auto_scheduler.zip"
  function_name    = "rds-auto-scheduler"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.13"
  timeout          = 300
  architectures    = ["arm64"]
  source_code_hash = data.local_file.lambda_zip.content_base64sha256

  depends_on = [aws_cloudwatch_log_group.rds_auto_scheduler, null_resource.build_lambda]
}

# Lambda Permissions
resource "aws_lambda_permission" "allow_eventbridge_start" {
  statement_id  = "AllowExecutionFromEventBridgeStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_auto_scheduler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rds_start.arn
}

resource "aws_lambda_permission" "allow_eventbridge_stop" {
  statement_id  = "AllowExecutionFromEventBridgeStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_auto_scheduler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rds_stop.arn
}
