resource "aws_lambda_function" "rds_snapshot_checker" {
  function_name    = "rds-snapshot-checker"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "app.lambda_handler"
  runtime          = "python3.12"
  filename         = "${path.module}/lambda/app.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/app.zip")
  timeout          = 300

  environment {
    variables = {
      SECRET_NAME       = aws_secretsmanager_secret.asana_personal_access_token.name
      ASANA_PROJECT_ID  = var.asana_project_id
      SNAPSHOT_AGE_DAYS = var.snapshot_age_days
    }
  }
}
