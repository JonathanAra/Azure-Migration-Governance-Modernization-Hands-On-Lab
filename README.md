# Azure-Migration-Governance-Modernization-Hands-On-Lab

[![Open in Azure Cloud Shell](https://img.shields.io/badge/Azure%20Cloud%20Shell-Open-blue?logo=microsoftazure)](https://shell.azure.com/bash)

![terraform-ci](https://github.com/<your-user>/<your-repo>/actions/workflows/terraform-ci.yml/badge.svg)
![tfsec](https://github.com/<your-user>/<your-repo>/actions/workflows/tfsec.yml/badge.svg)


## Goal: 
Simulate a VMware→Azure migration, prove post-migration operations & cost controls, and modernize one workload—all as code.

- Assessment: Azure Migrate (CSV import) → right-size & cost estimates

- Governance/IaC: Terraform landing zone with RBAC, Azure Policy (require tags, allowed locations & VM SKUs, deny NIC public IPs), Activity Log alerts, and budgets

- Modernization: Legacy API → Azure Container Apps (consumption, scale-to-zero)

- Cost posture: Near-$0 steady state; no VMs, no ASR replication running

### Tech Stack

Azure: Azure Migrate, (planned) Azure Site Recovery (ASR), Resource Groups, VNets/NSGs, Log Analytics, Monitor (Activity Log Alerts), Cost Management + Budgets, Azure Policy, RBAC, Azure Container Apps

IaC: Terraform (azurerm v4)

Practices: IaC, governance, right-sizing, cost optimization, DevOps-friendly guardrails


## Architecture
flowchart LR
  A[On-prem inventory (CSV)] -->|Upload| B[Azure Migrate Project]
  B --> C[Assessment: right-size & cost]
  C --> D[Landing Zone (Terraform): RGs, VNet/NSG]
  D --> E[Governance (Terraform): Policy + RBAC]
  E --> F[Ops Guardrails: Activity Log Alerts, Budgets]
  D --> G[Modernization: Azure Container Apps (consumption, scale-to-zero)]


## Repo Structure
infra/
  provider.tf
  variables.tf
  networking.tf
  policy.tf
  monitor.tf
  alerts.tf
  governance.tf
  app.tf
migrate/
  assessment-sample.csv
  assessment-notes.md
ops/
  update-manager-notes.md
screenshots/
  migrate-assessment.png
  container-app-overview.png

## Run the demo

### BASH

```bash
#1) Clone
git clone https://github.com/<your-username>/<your-azure-repo>.git
cd <your-azure-repo>/infra

#2 Confirm Subscription
az account set --subscription <your-subscription-id>

#3 Set Variables
cat > terraform.tfvars <<'EOF'
prefix               = "jmig01"
location             = "eastus"
alert_email          = "you@example.com"
enable_budget        = false
deploy_container_app = true
container_image      = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
EOF

#4 Deploy
terraform init -upgrade
terraform apply -auto-approve

#5 Get the app URL
PREFIX=jmig01
FQDN=$(az containerapp show -g ${PREFIX}-rg-workload -n ${PREFIX}-ca-legacy-api --query properties.configuration.ingress.fqdn -o tsv)
echo "https://$FQDN"
```


---

### Quick tips
- In **Bash**, set `PREFIX=jmig01` (don’t type `${var.prefix}` that’s Terraform syntax, not shell).  
- If you see “provider not registered: Microsoft.App”, run:
```bash

az provider register -n Microsoft.App --wait
```

## For Tear Down

``` Bash
# Destroy Everything
terraform destroy -auto-approve
```
## Results & Lessons

- Produced concrete right-size VM recommendations and monthly cost estimates with Azure Migrate

- Proved repeatable governance as code with Terraform (Policy, RBAC, alerts)

- Demonstrated a path from IaaS to Azure Container Apps with minimal resources and cold-start trade-offs

Keeping demos cost-safe makes iteration fast and realistic.


License

This repo is for educational/demo purposes. Use at your own risk.
