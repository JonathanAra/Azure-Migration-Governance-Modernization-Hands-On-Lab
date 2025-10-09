variable "prefix" {
  type    = string
  default = "jmig01"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "enable_budget" {
  type    = bool
  default = true
}

variable "monthly_budget_usd" {
  type    = number
  default = 5
}

variable "vnet_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "subnets" {
  type = map(string)
  default = {
    management = "10.20.1.0/24"
    workload   = "10.20.2.0/24"
  }
}

variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "admin_public_ip_cidr" {
  description = "Your public IP in CIDR, e.g. 203.0.113.4/32"
  type        = string
  default     = "0.0.0.0/0" # TEMPORARY; replace with your /32 below
}

variable "alert_email" {
  description = "Where to send alerts"
  type        = string
  default     = "you@example.com" # set yours or pass TF_VAR_alert_email
}

# Toggle: assign at subscription (true) or at workload RG (false)
variable "enable_subscription_assignment" {
  type    = bool
  default = false
}

# Which VM sizes are allowed (keep this tight = cheaper lab)
variable "allowed_vm_skus" {
  type    = list(string)
  default = ["Standard_B1s", "Standard_B2s"]
}

# Allowed regions. Leave empty to default to your platform RG's region.
variable "allowed_locations" {
  type    = list(string)
  default = []
}

# Optional: AAD objectId of a user/group/service principal to grant read access
variable "ops_reader_object_id" {
  type    = string
  default = ""
}

variable "deploy_container_app" {
  type    = bool
  default = true
}
variable "container_image" {
  type    = string
  default = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}
variable "container_cpu" {
  type    = number
  default = 0.25
} # vCPU
variable "container_memory" {
  type    = string
  default = "0.5Gi"
} # RAM

