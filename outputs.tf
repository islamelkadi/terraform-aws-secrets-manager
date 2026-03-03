# Secrets Manager Module Outputs

output "secret_id" {
  description = "Secret ID"
  value       = aws_secretsmanager_secret.this.id
}

output "secret_arn" {
  description = "Secret ARN"
  value       = aws_secretsmanager_secret.this.arn
}

output "secret_name" {
  description = "Secret name"
  value       = aws_secretsmanager_secret.this.name
}

output "version_id" {
  description = "Secret version ID (if secret value was provided)"
  value       = try(aws_secretsmanager_secret_version.this[0].version_id, null)
}

output "tags" {
  description = "Tags applied to the secret"
  value       = aws_secretsmanager_secret.this.tags
}

