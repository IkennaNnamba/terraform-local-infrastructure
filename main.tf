terraform {
  required_version = ">= 1.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "local" {}
provider "random" {}

# Simple naming convention and shared values
locals {
  resource_prefix = "${var.project_name}-${var.environment}"

  common_labels = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "Ikenna LTD"
  }

  app_config_content = <<-EOT
    # Application Configuration
    app_name = ${var.project_name}
    environment = ${var.environment}
    port = ${var.app_port}
    database = ${var.db_name}
  EOT

  db_config_content = <<-EOT
    # Database Configuration
    db_name = ${var.db_name}
    host = localhost
    port = 5432
  EOT
}

# Generate a random password for the database
resource "random_password" "db" {
  length           = 16
  special          = true
  override_special = "!@#$%^&*"

  lifecycle {
    prevent_destroy = true
  }
}

# Application config file
resource "local_file" "app_config" {
  filename        = "${path.module}/project/config/app.conf"
  content         = local.app_config_content
  file_permission = "0644"

  # Explicit dependency: this file's content doesn't reference
  # random_password.db directly, so Terraform wouldn't otherwise
  # know to sequence it after the password is created.
  depends_on = [random_password.db]
}

# Database config file
resource "local_file" "db_config" {
  filename        = "${path.module}/project/config/database.conf"
  content         = local.db_config_content
  file_permission = "0640"
}

# Store the generated password
# Implicit dependency: random_password.db.result is referenced directly
# in content, so Terraform infers the ordering automatically.
resource "local_file" "db_password" {
  filename        = "${path.module}/project/secrets/db_password.txt"
  content         = random_password.db.result
  file_permission = "0600"
}

# Read the generated password file back (data source)
data "local_file" "db_password_file" {
  filename = local_file.db_password.filename

  # Explicit dependency: needed because a data source has no automatic
  # way to know the file must be written before it reads it.
  depends_on = [local_file.db_password]
}

# Final deployment report
resource "local_file" "deployment_report" {
  filename        = "${path.module}/project/reports/deployment_report.txt"
  content         = <<-EOT
    ================================
    Deployment Report
    ================================
    Project      : ${var.project_name}
    Environment  : ${var.environment}
    App Port     : ${var.app_port}
    Database     : ${var.db_name}
    Generated At : ${timestamp()}

    Password Length : ${length(data.local_file.db_password_file.content)}
    Managed by      : Terraform
  EOT
  file_permission = "0644"

  depends_on = [
    local_file.app_config,
    local_file.db_config,
    local_file.db_password,
    data.local_file.db_password_file
  ]
}