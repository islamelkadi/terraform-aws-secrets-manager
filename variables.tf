# Secrets Manager Module Variables

# Metadata variables for consistent naming
variable "namespace" {
  description = "Namespace (organization/team name)"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

variable "name" {
  description = "Name of the secret"
  type        = string
}

variable "attributes" {
  description = "Additional attributes for naming"
  type        = list(string)
  default     = []
}

variable "delimiter" {
  description = "Delimiter to use between name components"
  type        = string
  default     = "-"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Secrets Manager specific variables
variable "description" {
  description = "Description of the secret"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "ARN of KMS key for encryption. If not provided, uses AWS managed key"
  type        = string
  default     = null
}

variable "recovery_window_in_days" {
  description = "Number of days to retain secret after deletion (7-30 days, 0 for immediate deletion)"
  type        = number
  default     = 30

  validation {
    condition     = var.recovery_window_in_days == 0 || (var.recovery_window_in_days >= 7 && var.recovery_window_in_days <= 30)
    error_message = "Recovery window must be 0 (immediate deletion) or between 7 and 30 days"
  }
}

variable "secret_string" {
  description = "Secret value as a string (JSON for structured data). Mutually exclusive with secret_binary"
  type        = string
  default     = null
  sensitive   = true
}

variable "secret_binary" {
  description = "Secret value as binary data. Mutually exclusive with secret_string"
  type        = string
  default     = null
  sensitive   = true
}

variable "create_secret_version" {
  description = "Whether to create an initial secret version. Set to false if secret value will be added manually later"
  type        = bool
  default     = true
}

variable "enable_rotation" {
  description = "Enable automatic secret rotation"
  type        = bool
  default     = false
}

variable "rotation_lambda_arn" {
  description = "ARN of Lambda function for secret rotation. Required if enable_rotation is true"
  type        = string
  default     = null
}

variable "rotation_days" {
  description = "Number of days between automatic rotations"
  type        = number
  default     = 30

  validation {
    condition     = var.rotation_days >= 1 && var.rotation_days <= 365
    error_message = "Rotation days must be between 1 and 365"
  }
}


variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

# Security controls
variable "security_controls" {
  description = "Security controls configuration from metadata module"
  type = object({
    encryption = object({
      require_kms_customer_managed  = bool
      require_encryption_at_rest    = bool
      require_encryption_in_transit = bool
      enable_kms_key_rotation       = bool
    })
    logging = object({
      require_cloudwatch_logs = bool
      min_log_retention_days  = number
      require_access_logging  = bool
      require_flow_logs       = bool
    })
    monitoring = object({
      enable_xray_tracing         = bool
      enable_enhanced_monitoring  = bool
      enable_performance_insights = bool
      require_cloudtrail          = bool
    })
    compliance = object({
      enable_point_in_time_recovery = bool
      require_reserved_concurrency  = bool
      enable_deletion_protection    = bool
    })
  })
  default = null
}

variable "security_control_overrides" {
  description = "Override specific security controls with documented justification"
  type = object({
    disable_kms_requirement            = optional(bool, false)
    disable_recovery_window_validation = optional(bool, false)
    justification                      = optional(string, "")
  })
  default = {
    disable_kms_requirement            = false
    disable_recovery_window_validation = false
    justification                      = ""
  }
}
