# ---- Look up existing Log Analytics workspace ----
data "azurerm_log_analytics_workspace" "law" {
  name                = "${var.prefix}-law"
  resource_group_name = azurerm_resource_group.platform.name
}

# ---- Container Apps Environment (v4: single workspace field, no logs{} block) ----
resource "azurerm_container_app_environment" "env" {
  count                      = var.deploy_container_app ? 1 : 0
  name                       = "${var.prefix}-cae"
  location                   = azurerm_resource_group.workload.location
  resource_group_name        = azurerm_resource_group.workload.name
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  tags                       = { env = "lab" }
}

# ---- Container App (public ingress, tiny footprint, autoscale 0..1) ----
resource "azurerm_container_app" "legacy_api" {
  count                        = var.deploy_container_app ? 1 : 0
  name                         = "${var.prefix}-ca-legacy-api"
  resource_group_name          = azurerm_resource_group.workload.name
  container_app_environment_id = azurerm_container_app_environment.env[0].id
  revision_mode                = "Single"

  template {
    container {
      name   = "api"
      image  = var.container_image
      cpu    = var.container_cpu
      memory = var.container_memory

      env {
        name  = "APP_ENV"
        value = "lab"
      }
    }

    min_replicas = 0
    max_replicas = 1
  }

  ingress {
    external_enabled = true
    target_port      = 80
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  tags = { env = "lab" }
}

