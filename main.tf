locals {
  enabled = var.target_resource_id != null || var.storage_account_id != null
}

data "azurerm_monitor_diagnostic_categories" "categories" {
  count       = local.enabled ? 1 : 0
  resource_id = var.target_resource_id
}

resource "azurerm_monitor_diagnostic_setting" "diagnostics" {
  count = local.enabled ? 1 : 0

  name                       = var.name
  target_resource_id         = var.target_resource_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_account_id         = var.storage_account_id

  dynamic "enabled_log" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.categories[0].log_category_types)

    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.categories[0].metrics)

    content {
      category = metric.value
    }
  }
}