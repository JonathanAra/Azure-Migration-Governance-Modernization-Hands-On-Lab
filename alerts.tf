# Subscription scope (delete this block if you already defined it elsewhere)


# Email action group (regional; no 'location' field required)
resource "azurerm_monitor_action_group" "ops_email" {
  name                = "${var.prefix}-ag-ops"
  resource_group_name = azurerm_resource_group.platform.name
  short_name          = "ops"

  email_receiver {
    name                    = "primary"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }

  tags = { env = "lab" }
}

# ---- Activity Log Alerts MUST be 'global' ----

resource "azurerm_monitor_activity_log_alert" "pip_created" {
  name                = "${var.prefix}-al-pip-write"
  resource_group_name = azurerm_resource_group.platform.name
  location            = "global" # <-- key fix
  scopes              = [data.azurerm_subscription.current.id]
  description         = "Notify when Public IPs are created/updated"

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Network/publicIPAddresses/write"
    status         = "Succeeded"
  }

  action { action_group_id = azurerm_monitor_action_group.ops_email.id }
  tags = { env = "lab" }
}

resource "azurerm_monitor_activity_log_alert" "vm_created" {
  name                = "${var.prefix}-al-vm-write"
  resource_group_name = azurerm_resource_group.platform.name
  location            = "global" # <-- key fix
  scopes              = [data.azurerm_subscription.current.id]
  description         = "Notify when VMs are created"

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Compute/virtualMachines/write"
    status         = "Succeeded"
  }

  action { action_group_id = azurerm_monitor_action_group.ops_email.id }
  tags = { env = "lab" }
}

resource "azurerm_monitor_activity_log_alert" "vm_started" {
  name                = "${var.prefix}-al-vm-start"
  resource_group_name = azurerm_resource_group.platform.name
  location            = "global" # <-- key fix
  scopes              = [data.azurerm_subscription.current.id]
  description         = "Notify when VMs are started"

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Compute/virtualMachines/start/action"
    status         = "Succeeded"
  }

  action { action_group_id = azurerm_monitor_action_group.ops_email.id }
  tags = { env = "lab" }
}

