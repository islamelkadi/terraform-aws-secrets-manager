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
