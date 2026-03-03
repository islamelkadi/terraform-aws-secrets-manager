# Basic Example Variables

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "namespace" {
  description = "Namespace (organization/team name)"
  type        = string
  default     = "example"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "name" {
  description = "Name of the secret"
  type        = string
  default     = "api-credentials"
}

variable "description" {
  description = "Description of the secret"
  type        = string
  default     = "API credentials for external service"
}

variable "kms_key_arn" {
  description = "ARN of KMS key for encryption"
  type        = string
  default     = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
}

variable "secret_string" {
  description = "Secret value as a string"
  type        = string
  sensitive   = true
  default     = null
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default = {
    Purpose = "API_CREDENTIALS"
    Team    = "PLATFORM"
  }
}
