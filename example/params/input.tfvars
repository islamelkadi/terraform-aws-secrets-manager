# Secrets Manager Module Example Input Variables

namespace   = "example"
environment = "dev"
name        = "api-credentials"
region      = "us-east-1"

description = "API credentials for external service"

# KMS key ARN for encryption (replace with your KMS key ARN)
kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

# Secret value as JSON string
secret_string = "{\"client_id\":\"demo-client-id\",\"client_secret\":\"demo-client-secret\",\"api_endpoint\":\"https://api.example.com/v1\"}"

tags = {
  Purpose = "API_CREDENTIALS"
  Team    = "PLATFORM"
}
