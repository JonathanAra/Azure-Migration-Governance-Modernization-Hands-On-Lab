# ---------- Budgets (RFC3339 dates) ----------
locals {
  now_utc      = timestamp()
  budget_start = "${formatdate("YYYY-MM", local.now_utc)}-01T00:00:00Z"
  budget_end   = "${formatdate("YYYY", local.now_utc)}-12-31T00:00:00Z"
}

data "azurerm_subscription" "current" {}

resource "azurerm_consumption_budget_subscription" "monthly" {
  count           = var.enable_budget ? 1 : 0
  name            = "${var.prefix}-monthly-budget"
  subscription_id = data.azurerm_subscription.current.id
  amount          = var.monthly_budget_usd
  time_grain      = "Monthly"

  time_period {
    start_date = local.budget_start
    end_date   = local.budget_end
  }

  notification {
    enabled        = true
    threshold      = 80.0
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = ["you@example.com"] # <-- set your real email
  }
}

