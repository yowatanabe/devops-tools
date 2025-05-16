resource "aws_cloudwatch_event_rule" "rds_snapshot_checker" {
  name                = "rds_snapshot_checker"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.rds_snapshot_checker.name
  target_id = "LambdaTarget"
  arn       = aws_lambda_function.rds_snapshot_checker.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_snapshot_checker.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rds_snapshot_checker.arn
}
