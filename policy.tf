
resource "azurerm_policy_definition" "require_tag_and_value" {
  name         = "${var.prefix}-poldef-require-tag-and-value"
  display_name = "Require a specific tag and value"
  mode         = "Indexed"
  policy_type  = "Custom"

  parameters = jsonencode({
    tagName = {
      type     = "String"
      metadata = { displayName = "Tag Name" }
    }
    tagValue = {
      type     = "String"
      metadata = { displayName = "Tag Value" }
    }
    effect = {
      type          = "String"
      metadata      = { displayName = "Effect" }
      allowedValues = ["Deny", "Audit"]
      defaultValue  = "Deny"
    }
  })

  policy_rule = jsonencode({
    if = {
      anyOf = [
        {
          field  = "[concat('tags[', parameters('tagName'), ']')]"
          exists = false
        },
        {
          field     = "[concat('tags[', parameters('tagName'), ']')]"
          notEquals = "[parameters('tagValue')]"
        }
      ]
    }
    then = {
      effect = "[parameters('effect')]"
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "require_tags" {
  name                 = "${var.prefix}-pol-assign-require-tag"
  resource_group_id    = azurerm_resource_group.platform.id
  policy_definition_id = azurerm_policy_definition.require_tag_and_value.id

  parameters = jsonencode({
    tagName  = { value = "env" }
    tagValue = { value = "lab" }
    effect   = { value = "Audit" } # TEMP: relax enforcement
  })
}


# Custom Policy: NICs must NOT have a Public IP

resource "azurerm_policy_definition" "nic_no_public_ip" {
  name         = "${var.prefix}-poldef-nic-no-public-ip"
  display_name = "Network interfaces should not have public IPs (custom)"
  mode         = "All"
  policy_type  = "Custom"

  # Deny NICs that have any ipConfiguration with a publicIpAddress attached
  policy_rule = jsonencode({
    if = {
      allOf = [
        { field = "type", equals = "Microsoft.Network/networkInterfaces" },
        {
          anyOf = [
            {
              field  = "Microsoft.Network/networkInterfaces/ipconfigurations[*].publicIpAddress.id"
              exists = true
            }
          ]
        }
      ]
    }
    then = { effect = "deny" }
  })
}

# Assign it to the workload RG
resource "azurerm_resource_group_policy_assignment" "deny_public_ip" {
  name                 = "${var.prefix}-pol-assign-deny-nic-public-ip"
  resource_group_id    = azurerm_resource_group.workload.id
  policy_definition_id = azurerm_policy_definition.nic_no_public_ip.id
}

