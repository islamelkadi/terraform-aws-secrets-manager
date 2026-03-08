# Primary Module Example - This demonstrates the terraform-aws-secrets-manager module
# Supporting infrastructure (KMS) is defined in separate files
# to keep this example focused on the module's core functionality.
#
# Secrets Manager Module Example
# Demonstrates secret creation with KMS encryption

module "secret" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  region      = var.region

  description = var.description
  
  # Direct reference to kms.tf module output
  kms_key_arn = module.kms_key.key_arn

  secret_string = var.secret_string

  tags = var.tags
}
