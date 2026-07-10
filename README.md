#                                     AWS Infrastructure Automation with Terraform & Jenkins

Automated provisioning of AWS infrastructure using Terraform, with a Jenkins CI/CD pipeline for multi-environment deployment (dev/prod), Slack notifications, and secrets management via AWS SSM Parameter Store.

## Overview

This project provisions a complete AWS environment — VPC, EC2, EKS, IAM, Security Groups, and RDS — using modular, reusable Terraform code. Deployments are driven through a Jenkins pipeline that supports `plan`, `apply`, and `destroy` actions across separate `dev` and `prod` environments, with manual approval gates before any production change.

## Architecture

```
                 ┌─────────────┐
                 │   GitHub    │
                 │ (source of  │
                 │   truth)    │
                 └──────┬──────┘
                        │ webhook / push
                        ▼
                 ┌─────────────┐
                 │   Jenkins   │
                 │  (EC2, IAM  │
                 │  instance   │
                 │    role)    │
                 └──────┬──────┘
                        │ terraform init/plan/apply
                        ▼
        ┌───────────────────────────────┐
        │            AWS                │
        │  VPC → Subnets → EC2 / EKS    │
        │  IAM Roles & Policies         │
        │  Security Groups              │
        │  RDS (encrypted, private)     │
        └───────────────────────────────┘
```

## Project Structure

```text
Terraform-Project/
|-- environment/
|   |-- dev/
|   |   |-- backend.tf          (S3 state backend - dev state path)
|   |   |-- main.tf             (Module calls with dev-specific values)
|   |   |-- variables.tf
|   |   |-- outputs.tf
|   |   `-- terraform.tfvars    (Non-sensitive dev config values)
|   `-- prod/
|       |-- backend.tf          (S3 state backend - prod state path)
|       |-- main.tf             (Module calls with prod-specific values)
|       |-- variables.tf
|       |-- outputs.tf
|       `-- terraform.tfvars    (Non-sensitive prod config values)
|-- modules/
|   |-- vpc/              (VPC, subnets, route tables)
|   |-- ec2/              (EC2 instances)
|   |-- eks/              (EKS cluster)
|   |-- iam/              (IAM roles and policies)
|   |-- security-group/   (Security groups)
|   `-- rds/              (RDS instance - MySQL/Postgres)
|-- Jenkinsfile           (CI/CD pipeline definition)
`-- README.md
```

Each environment folder calls the same shared modules with different input values — infrastructure logic lives once in `modules/`, and `dev`/`prod` only differ by configuration (instance sizes, counts, backend state paths).

## Prerequisites

- AWS account with an IAM role/user having permissions for VPC, EC2, EKS, IAM, RDS, S3, DynamoDB, and SSM
- Terraform >= 1.5
- Jenkins server (EC2-hosted, with an attached IAM instance role — no static AWS keys used)
- An S3 bucket + DynamoDB table for remote state and state locking (created once, outside Terraform — see below)
- A GitHub repository with a webhook pointed at the Jenkins server
- Slack workspace + app with a bot token for pipeline notifications

## One-Time Setup

### 1. Create the remote state backend

```bash
aws s3api create-bucket --bucket your-company-terraform-state --region us-east-1
aws s3api put-bucket-versioning --bucket your-company-terraform-state --versioning-configuration Status=Enabled

aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### 2. Store the RDS master password in SSM Parameter Store

```bash
aws ssm put-parameter \
  --name "/rds/dev-mysql/master_password" \
  --value "<your-dev-password>" \
  --type "SecureString"

aws ssm put-parameter \
  --name "/rds/prod-mysql/master_password" \
  --value "<your-prod-password>" \
  --type "SecureString"
```

### 3. Attach an IAM role to the Jenkins EC2 instance

Instead of static AWS access keys, the Jenkins server authenticates via an **EC2 instance profile**. The attached role needs permissions covering:
- S3 (state bucket read/write)
- DynamoDB (state lock table)
- SSM (`GetParameter`, `Decrypt` for `SecureString`)
- The AWS services being provisioned (VPC, EC2, EKS, IAM, RDS)

### 4. Configure the Jenkins job

- **Pipeline definition:** Pipeline script from SCM
- **SCM:** Git → repository URL + credentials (GitHub Personal Access Token, not password)
- **Branch:** `*/master`
- **Script path:** `Jenkinsfile`
- **Trigger:** GitHub hook trigger for GITScm polling (requires a matching webhook configured on the GitHub repo, pointed at `http://<jenkins-host>:8080/github-webhook/`)

### 5. Restrict builds to infrastructure-relevant changes

By default, every push to the repository triggers a build — including changes that have nothing to do with infrastructure, like a README edit. To avoid unnecessary builds, the Jenkins job is configured to only trigger when relevant paths change.

In the job's Pipeline configuration, under the Git SCM's Additional Behaviours, add "Polling ignores commits in certain paths" with:

Included Regions:

environment/.*
modules/.*
Jenkinsfile

With this in place, a commit that only touches README.md or other docs will not trigger a build. A commit touching anything under environment/, modules/, or the Jenkinsfile itself will trigger normally via the webhook.


## Running the Pipeline

### Automatic (on git push)

Every push to `master` triggers Jenkins via webhook. By default this runs `ENV=dev`, `ACTION=plan` — giving fast feedback on proposed changes without applying anything.

### Manual (Build with Parameters)

For anything beyond a dev plan — including all `apply`/`destroy` actions and anything touching `prod` — trigger the job manually:

1. Jenkins job → **Build with Parameters**
2. Choose:
   - **ENV:** `dev` or `prod`
   - **ACTION:** `plan`, `apply`, or `destroy`
3. Build

### Pipeline stages

1. **Checkout** — pulls the latest code from GitHub
2. **Init** — `terraform init` against the environment-specific backend
3. **Validate** — `terraform validate` + `terraform fmt -check`
4. **Security Scan** — `tfsec` static analysis
5. **Fetch Secrets** — pulls the RDS password from SSM and injects it as `TF_VAR_rds_db_password`
6. **Plan** — generates and archives the Terraform plan
7. **Publish Plan** — archives the plan output as a Jenkins build artifact
8. **Approval** *(prod + apply only)* — pauses for manual review and approval before proceeding
9. **Apply / Destroy** — executes the requested action
10. **Notify** — posts a Slack message with the plan summary and result

## Environment Safety

The `prod` environment automatically gets stricter defaults inside the RDS module, driven by the `environment` variable:

| Setting | dev | prod |
|---|---|---|
| Multi-AZ | No | Yes |
| Backup retention | 1 day | 7 days |
| Deletion protection | Off | On |
| Skip final snapshot | Yes | No |
| Apply requires manual approval | No | Yes |

## Secrets Management

Sensitive values (database passwords) are never committed to git or stored in `.tfvars`. They live in **AWS SSM Parameter Store** as `SecureString` values and are fetched by Jenkins at runtime, then passed to Terraform as an environment variable (`TF_VAR_rds_db_password`), which Terraform maps automatically to the `rds_db_password` input variable (marked `sensitive = true` so it never appears in logs or plan output).

## Notifications

Build results post to a Slack channel via the Jenkins Slack plugin, including:
- Success/failure/aborted status
- The `Plan: X to add, Y to change, Z to destroy` summary line
- A link back to the full Jenkins console output
- The full plan file, attached directly to the Slack message

## Tech Stack

- **IaC:** Terraform
- **Cloud:** AWS (VPC, EC2, EKS, IAM, RDS, S3, DynamoDB, SSM)
- **CI/CD:** Jenkins (Declarative Pipeline)
- **Source control:** GitHub
- **Security scanning:** tfsec
- **Notifications:** Slack

## Future Improvements

- Migrate pipeline logic into a Jenkins Shared Library for reuse across projects
- Add drift detection via scheduled `terraform plan` runs
- Enforce `tfsec` as a hard gate rather than a soft warning
- Add automated testing with Terratest
- Explore RDS IAM authentication to remove password-based auth entirely
