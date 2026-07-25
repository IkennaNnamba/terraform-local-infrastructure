variable "project_name" {
  type        = string
  description = "Name of the project"
  default     = "freefall-app"
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev, staging, prod)"
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, or prod."
  }
}

variable "app_port" {
  type        = number
  description = "Port the application will listen on"
  default     = 8080
}

variable "db_name" {
  type        = string
  description = "Name of the database"
  default     = "freefall-app-db"
}