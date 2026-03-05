variable "common_name" {
  type        = string
  description = "Common name prefix for all resources"
  default     = "serverless"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"
  default     = "dev"
}

variable "db_user_name" {
  type        = string
  description = "MySQL database account name"
  default     = "applets"
}

variable "db_password" {
  type        = string
  description = "MySQL database password, length 8-30, must contain three items (uppercase letters, lowercase letters, numbers, special symbols)"
  sensitive   = true
}