# Secrets Manager Module
# Creates AWS Secrets Manager secret with KMS encryption and optional rotation

resource "aws_secretsmanager_secret" "this" {
  name                    = local.secret_name
  description             = var.description
  kms_key_id              = var.kms_key_arn
  recovery_window_in_days = var.recovery_window_in_days

  tags = local.tags
}

# Secret version with initial value
# Note: Only created if create_secret_version is true
resource "aws_secretsmanager_secret_version" "this" {
  count = var.create_secret_version ? 1 : 0

  secret_id = aws_secretsmanager_secret.this.id

  # Use secret_string if provided, otherwise use secret_binary
  secret_string = var.secret_string
  secret_binary = var.secret_binary

  lifecycle {
    ignore_changes = [
      secret_string,
      secret_binary
    ]
  }
}

# Rotation configuration (if enabled)
resource "aws_secretsmanager_secret_rotation" "this" {
  count = var.enable_rotation ? 1 : 0

  secret_id           = aws_secretsmanager_secret.this.id
  rotation_lambda_arn = var.rotation_lambda_arn

  rotation_rules {
    automatically_after_days = var.rotation_days
  }
}

