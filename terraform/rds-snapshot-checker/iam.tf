data "aws_iam_policy_document" "lambda_exec_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "lambda-rds-snapshot-checker"
  assume_role_policy = data.aws_iam_policy_document.lambda_exec_assume_role_policy.json
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect    = "Allow"
    actions   = ["rds:DescribeDBSnapshots", "rds:DescribeDBClusterSnapshots"]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.asana_personal_access_token.arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "lambda-rds-snapshot-policy"
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
