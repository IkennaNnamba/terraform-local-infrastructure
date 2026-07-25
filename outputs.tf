output "project_name" {
  description = "Name of the project"
  value       = var.project_name
}

output "environment" {
  description = "Current environment"
  value       = var.environment
}

output "app_config_path" {
  description = "Path to the application config file"
  value       = local_file.app_config.filename
}

output "db_config_path" {
  description = "Path to the database config file"
  value       = local_file.db_config.filename
}

output "db_password_path" {
  description = "Path to the generated database password file"
  value       = local_file.db_password.filename
  sensitive   = true
}

output "deployment_report_path" {
  description = "Path to the deployment report"
  value       = local_file.deployment_report.filename
}