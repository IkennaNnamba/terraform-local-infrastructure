# Terraform Local Infrastructure Assignment

This project demonstrates core Terraform concepts by generating local configuration files for a sample application, without deploying to any cloud provider.

## What This Project Does

After running `terraform apply`, the following structure is created:

```
project/
├── config/
│   ├── app.conf
│   └── database.conf
├── secrets/
│   └── db_password.txt
└── reports/
    └── deployment_report.txt
```

## Concepts Covered

| Concept | Where it's demonstrated |
|---|---|
| Input variables | `variables.tf` (`project_name`, `environment`, `app_port`, `db_name`) |
| Variable values via `.tfvars` | `terraform.tfvars` |
| Variable referencing | Used throughout `locals` and resource blocks in `main.tf` |
| Resource attributes | Outputs reference `.filename` from `local_file` resources |
| Implicit dependency | `local_file.db_password` references `random_password.db.result` directly |
| Explicit dependency | `depends_on` on `local_file.app_config`, `data.local_file.db_password_file`, and `local_file.deployment_report` |
| Multiple providers | `hashicorp/local` and `hashicorp/random` |
| Locals | `local.resource_prefix`, `local.common_labels`, `local.app_config_content`, `local.db_config_content` |
| Lifecycle rules | `prevent_destroy = true` on `random_password.db`, protecting the generated secret from accidental rotation |
| Data sources | `data.local_file.db_password_file` reads back the generated password file |
| Outputs | `outputs.tf` — file paths and metadata |

## How to Run

1. Initialize the project:
```bash
terraform init
```

2. Preview the changes:
```bash
terraform plan
```

3. Apply the configuration:
```bash
terraform apply
```

4. To destroy — note that `random_password.db` is protected with `prevent_destroy`, so a full `terraform destroy` will fail on that resource by design. Remove the lifecycle block first if a full teardown is needed:
```bash
terraform destroy
```

## Files

- `main.tf` – Main configuration (providers, locals, resources, data source)
- `variables.tf` – Input variable declarations
- `terraform.tfvars` – Variable values
- `outputs.tf` – Output values