# Secrets Manager Module Example
# Demonstrates secret creation with KMS encryption

module "secret" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  region      = var.region

  description = var.description
  kms_key_arn = var.kms_key_arn

  secret_string = var.secret_string

  tags = var.tags
}
