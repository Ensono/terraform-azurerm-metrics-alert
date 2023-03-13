resource "azurerm_monitor_action_group" "default" {
  for_each            = var.action_group
  name                = "${var.action_name_prefix}-${each.key}"
  resource_group_name = each.value.resource_group_name
  # take the last 12 characters instead of the first
  short_name          = substr(each.value.short_name, length(each.value.short_name) - 12, length(each.value.short_name))
  enabled             = try(each.value.enabled, false)

  dynamic "email_receiver" {
    for_each = each.value.email_receiver
    content {
      name                    = "${var.action_name_prefix}-${email_receiver.key}"
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = try(email_receiver.value.use_common_alert_schema, false)
    }
  }
  tags = merge(var.tags, try(each.value.tags, {}))
}

resource "azurerm_monitor_metric_alert" "default" {
  for_each                 = var.metric_alert
  name                     = "${var.alert_name_prefix}-${each.key}"
  resource_group_name      = each.value.resource_group_name
  scopes                   = each.value.scopes
  description              = format(var.alert_description, each.value.description)
  severity                 = each.value.severity
  enabled                  = try(each.value.enabled, true)
  frequency                = try(each.value.frequency, "PT5M") /// PT1M, PT5M, PT15M, PT30M and PT1H
  window_size              = try(each.value.window_size, "PT5M")
  target_resource_location = try(each.value.target_resource_location, null)

  # not required in the current iteration
  # can be introduced later on 
  #   dynamic "dynamic_criteria" {
  #     for_each = length(each.value.dynamic_criteria) > 0 ? each.value.dynamic_criteria : toset([])
  #     content {
  #     }
  #   }

  # criteria can be 
  dynamic "criteria" {
    for_each = try(each.value.criteria, {})
    content {
      metric_namespace = criteria.value.metric_namespace // "Microsoft.ServiceBus/namespaces"
      metric_name      = criteria.value.metric_name      //"DeadletteredMessages"
      aggregation      = criteria.value.aggregation      // "Average"
      operator         = criteria.value.operator         // "GreaterThan"
      threshold        = criteria.value.threshold        // each.value.threshold

      # not all alerts will require a drill down dimension
      # e.g. alerts on the ServiceBus itself
      dynamic "dimension" {
        for_each = length(criteria.value.dimension_name) > 0 ? [1] : []
        content {
          name     = criteria.value.dimension_name     // "EntityName"
          operator = criteria.value.dimension_operator //"Include"
          values   = criteria.value.dimension_values
        }
      }
    }
  }

  dynamic "action" {
    # Add additional actions to a default group 
    for_each = merge({ for i, j in azurerm_monitor_action_group.default : i => { action_group_id : j.id } },
    { for k, v in each.value.action_map : v.action_group_id => v... if v.action_group_id != "" })
    content {
      action_group_id    = action.value.action_group_id
      webhook_properties = try(action.value.webhook_properties, null)
    }
  }

  #  add additional tags to default 
  tags = merge(var.tags, try(each.value.tags, {}))
}
