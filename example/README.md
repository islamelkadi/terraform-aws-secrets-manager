# Secrets Manager Module Example

This example demonstrates how to use the Secrets Manager module to create encrypted secrets.

## Features Demonstrated

- Secret creation with KMS encryption
- JSON-formatted secret values
- Metadata-based naming and tagging

## Usage

1. Update `params/input.tfvars` with your values:
   - Replace `kms_key_arn` with your KMS key ARN
   - Update `secret_string` with your actual secret data
   - Modify tags as needed

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Plan the deployment:
   ```bash
   terraform plan -var-file=params/input.tfvars
   ```

4. Apply the configuration:
   ```bash
   terraform apply -var-file=params/input.tfvars
   ```

## Secret Format

The example uses JSON format for the secret value:

```json
{
  "client_id": "demo-client-id",
  "client_secret": "demo-client-secret",
  "api_endpoint": "https://api.example.com/v1"
}
```

You can modify this structure to match your application's requirements.

## Prerequisites

- AWS KMS key for encryption
- Appropriate IAM permissions to create secrets

## Outputs

- `secret_arn` - ARN of the created secret
- `secret_name` - Name of the secret
- `secret_id` - ID of the secret

## Security Notes

- Never commit actual secrets to version control
- Use environment variables or secure parameter stores for real credentials
- Enable automatic rotation for production secrets
- Use least-privilege IAM policies for secret access

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.34 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | git::https://github.com/islamelkadi/terraform-aws-kms.git | v1.0.0 |
| <a name="module_secret"></a> [secret](#module\_secret) | ../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | Description of the secret | `string` | `"API credentials for external service"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `"dev"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the secret | `string` | `"api-credentials"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) | `string` | `"example"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_secret_string"></a> [secret\_string](#input\_secret\_string) | Secret value as a string | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags | `map(string)` | <pre>{<br/>  "Purpose": "API_CREDENTIALS",<br/>  "Team": "PLATFORM"<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
