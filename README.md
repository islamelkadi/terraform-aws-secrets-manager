# Terraform AWS Secrets Manager Module

A reusable Terraform module for creating AWS Secrets Manager secrets with AWS Security Hub compliance (FSBP, CIS, NIST 800-53, NIST 800-171, PCI DSS), KMS encryption, automatic rotation, and flexible security control overrides.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Security](#security)
- [Features](#features)
- [Usage](#usage)
- [Requirements](#requirements)
- [MCP Servers](#mcp-servers)

## Prerequisites

This module is designed for macOS. The following must already be installed on your machine:
- Python 3 and pip
- [Kiro](https://kiro.dev) and Kiro CLI
- [Homebrew](https://brew.sh)

To install the remaining development tools, run:

```bash
make bootstrap
```

This will install/upgrade: tfenv, Terraform (via tfenv), tflint, terraform-docs, checkov, and pre-commit.

## Security

### Security Controls

This module implements AWS Security Hub compliance with an extensible override system.

### Available Security Control Overrides

| Override Flag | Description | Common Justification |
|--------------|-------------|---------------------|
| `disable_kms_requirement` | Allows AWS-managed encryption | "Development secret, no sensitive data" |
| `disable_recovery_window_validation` | Allows immediate deletion | "Test secret, faster teardown needed" |

### Security Best Practices

**Production Secrets:**
- Use KMS customer-managed keys
- Set recovery window to 30 days (maximum)
- Enable automatic rotation where possible
- Use IAM policies to restrict access
- Enable CloudTrail logging for secret access

**Development Secrets:**
- KMS encryption still recommended
- Shorter recovery window acceptable (7-14 days)

### Environment-Based Security Controls

Security controls are automatically applied based on the environment through the [terraform-aws-metadata](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles) module's security profiles:

| Control | Dev | Staging | Prod |
|---------|-----|---------|------|
| KMS customer-managed keys | Optional | Required | Required |
| Recovery window | 7 days | 14-30 days | 30 days |
| Automatic rotation | Optional | Recommended | Required |
| IAM access restriction | Enforced | Enforced | Enforced |

For full details on security profiles and how controls vary by environment, see the [Security Profiles](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles) documentation.

### Security Scan Suppressions

This module suppresses certain Checkov security checks that are either not applicable to example/demo code or represent optional features. The following checks are suppressed in `.checkov.yaml`:

**Module Source Versioning (CKV_TF_1, CKV_TF_2)**
- Suppressed because we use semantic version tags (`?ref=v1.0.0`) instead of commit hashes for better maintainability and readability
- Semantic versioning is a valid and widely-accepted versioning strategy for stable releases

**KMS IAM Policies (CKV_AWS_111, CKV_AWS_356, CKV_AWS_109)**
- Suppressed in example code where KMS modules use flexible IAM policies for demonstration purposes
- Production deployments should customize KMS policies based on specific security requirements and apply least privilege principles

## Features

- AWS Secrets Manager secret
- KMS encryption with customer-managed keys
- Automatic secret rotation support
- Configurable recovery window (7-30 days)
- Secret versioning
- Security controls integration

## Usage Examples

### Basic Example

```hcl
module "secret" {
  source = "github.com/islamelkadi/terraform-aws-secrets-manager"
  namespace   = "example"
  environment = "prod"
  name        = "database-password"
  region      = "us-east-1"
  
  description = "RDS database master password"
  
  secret_string = jsonencode({
    username = "admin"
    password = "change-me-in-production"
  })
  
  kms_key_arn = module.kms.key_arn
  
  tags = {
    Project = "CorporateActions"
  }
}
```

### Production Secret with Security Controls

```hcl
module "secret" {
  source = "github.com/islamelkadi/terraform-aws-secrets-manager"
  security_controls = module.metadata.security_controls
  
  namespace   = "example"
  environment = "prod"
  name        = "corporate-actions-db-credentials"
  region      = "us-east-1"
  
  description = "Database credentials for Corporate Actions application"
  
  # Store as JSON for structured data
  secret_string = jsonencode({
    username = "app_user"
    password = random_password.db_password.result
    host     = module.rds.endpoint
    port     = 5432
    database = "corporate_actions"
  })
  
  # KMS encryption (required by security controls)
  kms_key_arn = module.kms.key_arn
  
  # Maximum recovery window for production
  recovery_window_in_days = 30
  
  # Enable automatic rotation
  enable_rotation      = true
  rotation_days        = 30
  rotation_lambda_arn  = module.rotation_lambda.function_arn
  
  tags = {
    Project    = "CorporateActions"
    DataClass  = "Confidential"
    Compliance = "PCI-DSS"
  }
}

# Lambda function for secret rotation
module "rotation_lambda" {
  source = "github.com/islamelkadi/terraform-aws-secrets-manager"
  namespace   = "example"
  environment = "prod"
  name        = "secret-rotation"
  region      = "us-east-1"
  
  runtime = "python3.13"
  handler = "index.handler"
  filename = "rotation.zip"
  
  vpc_config = {
    subnet_ids         = module.vpc.private_subnet_ids
    security_group_ids = [module.lambda_sg.id]
  }
  
  environment_variables = {
    DB_ENDPOINT = module.rds.endpoint
  }
}
```

### API Key Secret

```hcl
module "api_key_secret" {
  source = "github.com/islamelkadi/terraform-aws-secrets-manager"
  security_controls = module.metadata.security_controls
  
  namespace   = "example"
  environment = "prod"
  name        = "external-api-key"
  region      = "us-east-1"
  
  description = "API key for external service integration"
  
  secret_string = jsonencode({
    api_key    = var.external_api_key
    api_secret = var.external_api_secret
    endpoint   = "https://api.external-service.com"
  })
  
  kms_key_arn             = module.kms.key_arn
  recovery_window_in_days = 30
  
  tags = {
    Project = "CorporateActions"
    Purpose = "ExternalIntegration"
  }
}

# Lambda can retrieve secret at runtime
module "api_lambda" {
  source = "github.com/islamelkadi/terraform-aws-secrets-manager"
  namespace   = "example"
  environment = "prod"
  name        = "api-client"
  region      = "us-east-1"
  
  runtime = "python3.13"
  handler = "index.handler"
  filename = "api-client.zip"
  
  environment_variables = {
    SECRET_ARN = module.api_key_secret.secret_arn
  }
  
  # Grant permission to read secret
  inline_policies = {
    secrets_access = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = module.api_key_secret.secret_arn
      }]
    })
  }
}
```

### Development Secret with Overrides

```hcl
module "dev_secret" {
  source = "github.com/islamelkadi/terraform-aws-secrets-manager"
  security_controls = module.metadata.security_controls
  
  security_control_overrides = {
    disable_recovery_window_validation = true
    justification = "Development secret for testing. Faster teardown needed for ephemeral environments. No production data."
  }
  
  namespace   = "example"
  environment = "dev"
  name        = "test-credentials"
  region      = "us-east-1"
  
  description = "Test credentials for development"
  
  secret_string = jsonencode({
    username = "test_user"
    password = "test_password"
  })
  
  # Still use KMS encryption
  kms_key_arn = module.kms.key_arn
  
  # Shorter recovery window for dev
  recovery_window_in_days = 7
  
  tags = {
    Project     = "CorporateActions"
    Environment = "Development"
  }
}
```

## MCP Servers

This module includes two [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) servers configured in `.kiro/settings/mcp.json` for use with Kiro:

| Server | Package | Description |
|--------|---------|-------------|
| `aws-docs` | `awslabs.aws-documentation-mcp-server@latest` | Provides access to AWS documentation for contextual lookups of service features, API references, and best practices. |
| `terraform` | `awslabs.terraform-mcp-server@latest` | Enables Terraform operations (init, validate, plan, fmt, tflint) directly from the IDE with auto-approved commands for common workflows. |

Both servers run via `uvx` and require no additional installation beyond the [bootstrap](#prerequisites) step.

<!-- BEGIN_TF_DOCS -->

## Usage

```hcl
# Secrets Manager Module Example
# Demonstrates secret creation with KMS encryption

module "secret" {
  source = "github.com/islamelkadi/terraform-aws-secrets-manager"
  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  region      = var.region

  description = var.description
  kms_key_arn = var.kms_key_arn

  secret_string = var.secret_string

  tags = var.tags
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.34 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.34 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_metadata"></a> [metadata](#module\_metadata) | github.com/islamelkadi/terraform-aws-metadata | v1.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_rotation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_rotation) | resource |
| [aws_secretsmanager_secret_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes for naming | `list(string)` | `[]` | no |
| <a name="input_create_secret_version"></a> [create\_secret\_version](#input\_create\_secret\_version) | Whether to create an initial secret version. Set to false if secret value will be added manually later | `bool` | `true` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to use between name components | `string` | `"-"` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the secret | `string` | `""` | no |
| <a name="input_enable_rotation"></a> [enable\_rotation](#input\_enable\_rotation) | Enable automatic secret rotation | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of KMS key for encryption. If not provided, uses AWS managed key | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the secret | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) | `string` | n/a | yes |
| <a name="input_recovery_window_in_days"></a> [recovery\_window\_in\_days](#input\_recovery\_window\_in\_days) | Number of days to retain secret after deletion (7-30 days, 0 for immediate deletion) | `number` | `30` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region where resources will be created | `string` | n/a | yes |
| <a name="input_rotation_days"></a> [rotation\_days](#input\_rotation\_days) | Number of days between automatic rotations | `number` | `30` | no |
| <a name="input_rotation_lambda_arn"></a> [rotation\_lambda\_arn](#input\_rotation\_lambda\_arn) | ARN of Lambda function for secret rotation. Required if enable\_rotation is true | `string` | `null` | no |
| <a name="input_secret_binary"></a> [secret\_binary](#input\_secret\_binary) | Secret value as binary data. Mutually exclusive with secret\_string | `string` | `null` | no |
| <a name="input_secret_string"></a> [secret\_string](#input\_secret\_string) | Secret value as a string (JSON for structured data). Mutually exclusive with secret\_binary | `string` | `null` | no |
| <a name="input_security_control_overrides"></a> [security\_control\_overrides](#input\_security\_control\_overrides) | Override specific security controls with documented justification | <pre>object({<br/>    disable_kms_requirement            = optional(bool, false)<br/>    disable_recovery_window_validation = optional(bool, false)<br/>    justification                      = optional(string, "")<br/>  })</pre> | <pre>{<br/>  "disable_kms_requirement": false,<br/>  "disable_recovery_window_validation": false,<br/>  "justification": ""<br/>}</pre> | no |
| <a name="input_security_controls"></a> [security\_controls](#input\_security\_controls) | Security controls configuration from metadata module | <pre>object({<br/>    encryption = object({<br/>      require_kms_customer_managed  = bool<br/>      require_encryption_at_rest    = bool<br/>      require_encryption_in_transit = bool<br/>      enable_kms_key_rotation       = bool<br/>    })<br/>    logging = object({<br/>      require_cloudwatch_logs = bool<br/>      min_log_retention_days  = number<br/>      require_access_logging  = bool<br/>      require_flow_logs       = bool<br/>    })<br/>    monitoring = object({<br/>      enable_xray_tracing         = bool<br/>      enable_enhanced_monitoring  = bool<br/>      enable_performance_insights = bool<br/>      require_cloudtrail          = bool<br/>    })<br/>    compliance = object({<br/>      enable_point_in_time_recovery = bool<br/>      require_reserved_concurrency  = bool<br/>      enable_deletion_protection    = bool<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_secret_arn"></a> [secret\_arn](#output\_secret\_arn) | Secret ARN |
| <a name="output_secret_id"></a> [secret\_id](#output\_secret\_id) | Secret ID |
| <a name="output_secret_name"></a> [secret\_name](#output\_secret\_name) | Secret name |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the secret |
| <a name="output_version_id"></a> [version\_id](#output\_version\_id) | Secret version ID (if secret value was provided) |

## Example

See [example/](example/) for a complete working example with all features.

<!-- END_TF_DOCS -->
