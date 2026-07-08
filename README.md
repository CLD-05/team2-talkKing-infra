# TalkKing Infrastructure

Terraform code for the TalkKing AWS infrastructure.

## Structure

```text
infra/
├── bootstrap-backend/         # One-time S3 backend bootstrap
├── modules/                   # Reusable environment-neutral modules
│   ├── network/
│   ├── bastion/
│   ├── eks/
│   ├── addons/
│   ├── database/
│   ├── ecr/
│   ├── elasticache/
│   ├── github_oidc/
│   ├── route53/
│   ├── s3/
│   └── secrets/
└── envs/
    ├── dev/
    │   ├── infra/             # VPC, EKS, RDS, Redis, IAM, ECR
    │   └── platform-addons/   # Helm/Kubernetes addons after EKS exists
    └── prod/
        ├── infra/
        └── platform-addons/
```

## Principles

- `modules/*` are reusable parts and do not contain backend or tfvars files.
- `envs/*` directories are Terraform execution roots.
- `dev` and `prod` are separated by directories, not workspaces.
- `infra` and `platform-addons` are separated so Helm/Kubernetes providers initialize only after EKS exists.
- S3 backend locking uses `use_lockfile = true`; DynamoDB lock tables are not used.
- AWS resources must include `Team = "team2"`, `Project`, and `Environment` tags.
- IAM roles created by Terraform must use the `TeamRuntimeBoundary` permissions boundary.
- Commit `backend.tf.example` and `terraform.tfvars.example`.
- Do not commit `backend.tf` or `terraform.tfvars`.

## Execution

```powershell
# 1. Bootstrap backend once
cd infra/bootstrap-backend
Copy-Item terraform.tfvars.example terraform.tfvars
terraform init
terraform apply

# 2. Create dev AWS infra
cd ../envs/dev/infra
Copy-Item backend.tf.example backend.tf
Copy-Item terraform.tfvars.example terraform.tfvars
terraform init
terraform apply

# 3. Install dev platform addons
cd ../platform-addons
Copy-Item backend.tf.example backend.tf
Copy-Item terraform.tfvars.example terraform.tfvars
# Fill cluster_name, vpc_id, and role ARNs from ../infra terraform output.
terraform init
terraform apply
```

Prod follows the same flow under `infra/envs/prod`.
