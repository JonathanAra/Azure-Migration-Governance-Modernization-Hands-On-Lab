# Azure-Migration-Governance-Modernization-Hands-On-Lab

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

### Option A — Azure Cloud Shell (recommended)
```bash
git clone https://github.com/<your-username>/<your-azure-repo>.git
cd <your-azure-repo>/infra
az account set --subscription <your-subscription-id>
cat > terraform.tfvars <<'EOF'
prefix               = "jmig01"
location             = "eastus"
alert_email          = "you@example.com"
enable_budget        = false
deploy_container_app = true
container_image      = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
EOF
terraform init -upgrade
terraform apply -auto-approve
PREFIX=jmig01
FQDN=$(az containerapp show -g ${PREFIX}-rg-workload -n ${PREFIX}-ca-legacy-api --query properties.configuration.ingress.fqdn -o tsv)
echo "https://$FQDN"

