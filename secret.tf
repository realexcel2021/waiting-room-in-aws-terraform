resource "aws_secretsmanager_secret" "redis_auth" {
  description = "Auth for Redis"
  name        = "${var.project_name}/redis-auth"
  recovery_window_in_days = 0

  kms_key_id = "alias/aws/secretsmanager"

}

resource "random_password" "password" {
  length           = 128
  special          = false
}

resource "aws_secretsmanager_secret_version" "redis_auth" {
  secret_id     = aws_secretsmanager_secret.redis_auth.id
  secret_string = random_password.password.result
}

data "aws_secretsmanager_secret_version" "redis_auth" {
  secret_id = aws_secretsmanager_secret.redis_auth.id

  depends_on = [ aws_secretsmanager_secret_version.redis_auth ]
}
