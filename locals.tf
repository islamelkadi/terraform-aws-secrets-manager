# Local values for naming and tagging

locals {
  # Use metadata module for standardized naming
  secret_name_base = module.metadata.resource_prefix

  # Construct secret name from components (with optional attributes)
  secret_name = length(var.attributes) > 0 ? "${local.secret_name_base}-${join(var.delimiter, var.attributes)}" : local.secret_name_base

  # Merge tags with defaults
  tags = merge(
    var.tags,
    module.metadata.security_tags,
    {
      Name   = local.secret_name
      Module = "terraform-aws-secrets-manager"
    }
  )
}
