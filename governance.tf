locals {
  policy_allowed_locations = length(var.allowed_locations) > 0 ? var.allowed_locations : [azurerm_resource_group.platform.location]
}


# Custom: Allowed Locations 
resource "azurerm_policy_definition" "allowed_locations" {
  name         = "${var.prefix}-poldef-allowed-locations"
  display_name = "Allowed locations (lab)"
  mode         = "All"
  policy_type  = "Custom"

  parameters = jsonencode({
    allowedLocations = {
      type     = "Array"
      metadata = { displayName = "Allowed locations" }
    }
    effect = {
      type          = "String"
      allowedValues = ["Deny", "Audit"]
      defaultValue  = "Deny"
      metadata      = { displayName = "Effect" }
    }
  })

  policy_rule = jsonencode({
    if = {
      not = {
        field = "location"
        in    = "[parameters('allowedLocations')]"
      }
    }
    then = { effect = "[parameters('effect')]" }
  })
}

# Custom: Allowed VM SKUs 
resource "azurerm_policy_definition" "allowed_vm_skus" {
  name         = "${var.prefix}-poldef-allowed-vm-skus"
  display_name = "Allowed VM SKUs (lab)"
  mode         = "All"
  policy_type  = "Custom"

  parameters = jsonencode({
    listOfAllowedSKUs = {
      type     = "Array"
      metadata = { displayName = "Allowed VM SKUs" }
    }
    effect = {
      type          = "String"
      allowedValues = ["Deny", "Audit"]
      defaultValue  = "Deny"
      metadata      = { displayName = "Effect" }
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        { field = "type", equals = "Microsoft.Compute/virtualMachines" },
        {
          not = {
            field = "Microsoft.Compute/virtualMachines/sku.name"
            in    = "[parameters('listOfAllowedSKUs')]"
          }
        }
      ]
    }
    then = { effect = "[parameters('effect')]" }
  })
}

# Policy Set: Landing Zone Baseline
# Reuses your existing custom policies:

resource "azurerm_policy_set_definition" "lz_baseline" {
  name         = "${var.prefix}-polset-lz-baseline"
  display_name = "Landing Zone Baseline (lab)"
  policy_type  = "Custom"

  # Require tag env=lab
  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.require_tag_and_value.id
    reference_id         = "require_tag_label"
    parameter_values = jsonencode({
      tagName  = { value = "env" }
      tagValue = { value = "lab" }
      effect   = { value = "Deny" }
    })
  }

  # Deny NICs with Public IP
  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.nic_no_public_ip.id
    reference_id         = "deny_nic_public_ip"
  }

  # Allowed locations
  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.allowed_locations.id
    reference_id         = "allowed_locations"
    parameter_values = jsonencode({
      allowedLocations = { value = local.policy_allowed_locations }
      effect           = { value = "Deny" }
    })
  }

  # Allowed VM SKUs
  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.allowed_vm_skus.id
    reference_id         = "allowed_vm_skus"
    parameter_values = jsonencode({
      listOfAllowedSKUs = { value = var.allowed_vm_skus }
      effect            = { value = "Deny" }
    })
  }
}


resource "azurerm_subscription_policy_assignment" "lz_baseline_sub" {
  count                = var.enable_subscription_assignment ? 1 : 0
  name                 = "${var.prefix}-polassign-lz-baseline-sub"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_set_definition.lz_baseline.id
  description          = "Landing zone baseline at subscription"
}

resource "azurerm_resource_group_policy_assignment" "lz_baseline_rg" {
  count                = var.enable_subscription_assignment ? 0 : 1
  name                 = "${var.prefix}-polassign-lz-baseline-rg"
  resource_group_id    = azurerm_resource_group.workload.id
  policy_definition_id = azurerm_policy_set_definition.lz_baseline.id
  description          = "Landing zone baseline at workload RG"
  # Assigning at RG keeps perms simple if you can't assign at subscription
}

# RBAC
# Grant a user/group read-only on workload RG (and cost read on subscription) if you supply ops_reader_object_id
data "azurerm_role_definition" "reader" {
  name  = "Reader"
  scope = azurerm_resource_group.workload.id
}

data "azurerm_role_definition" "cost_reader" {
  name  = "Cost Management Reader"
  scope = data.azurerm_subscription.current.id
}

resource "azurerm_role_assignment" "ops_reader_on_workload_rg" {
  count              = var.ops_reader_object_id != "" ? 1 : 0
  scope              = azurerm_resource_group.workload.id
  role_definition_id = data.azurerm_role_definition.reader.role_definition_id
  principal_id       = var.ops_reader_object_id
}

resource "azurerm_role_assignment" "ops_cost_reader_on_sub" {
  count              = var.ops_reader_object_id != "" ? 1 : 0
  scope              = data.azurerm_subscription.current.id
  role_definition_id = data.azurerm_role_definition.cost_reader.role_definition_id
  principal_id       = var.ops_reader_object_id
}
