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
