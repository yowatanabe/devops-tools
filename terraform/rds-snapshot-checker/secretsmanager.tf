resource "aws_secretsmanager_secret" "asana_personal_access_token" {
  name        = "Asana/PersonalAccessToken"
  description = "Asana Personal Access Token"
}

resource "aws_secretsmanager_secret_version" "asana_personal_access_token_version" {
  secret_id     = aws_secretsmanager_secret.asana_personal_access_token.id
  secret_string = jsonencode({ ASANA_TOKEN = var.asana_personal_token_value })
}
