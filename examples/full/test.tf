terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "1.5.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.99.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

variable "name" {
  type = string
  default = "dn.metrics"
  description = "(optional) describe your variable"
}

module "default_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.24.1"
  namespace  = format("%s-%s", "test", "local")
  stage      = "test"
  name       = var.name 
  attributes = []
  delimiter  = "-"
  tags = merge({}, {
    Company     = "Org"
    Billing     = "cloud-technology"
    Environment = "dev" //var.stage
    ManagedBy   = "Terraform"
    BranchName  = "feat-test" // var.commit_branch
    # CommitSha   = var.commit_sha
    }
  )
}

locals {
  test_input = { main : {}, compute : {} }
}

resource "azurerm_resource_group" "default" {
  for_each = local.test_input
  name     = "${module.default_label.id}-${each.key}"
  location = "North Europe"
  tags     = merge(module.default_label.tags, { Name : each.key })
}

resource "azurerm_servicebus_namespace" "default" {
  name                = module.default_label.id
  location            = azurerm_resource_group.default["main"].location
  resource_group_name = azurerm_resource_group.default["main"].name
  sku                 = "Standard"
  tags                = module.default_label.tags
}

resource "azurerm_servicebus_queue" "default" {
  count               = 10
  name                = "${module.default_label.id}~default~${count.index}"
  namespace_id        = azurerm_servicebus_namespace.default.id
  enable_partitioning = false
}

resource "azurerm_servicebus_queue" "default_2" {
  count               = 20
  name                = "${module.default_label.id}~default_2~${count.index}"
  namespace_id        = azurerm_servicebus_namespace.default.id
  enable_partitioning = false
}

# # TEST VARS 
# variable "METRIC_ALERT" {
#   type = any
#   default = {}
#   description = "(optional) describe your variable"
# }

# locals {
#   enriched_alerts = { for topkey, topvalue in var.METRIC_ALERT : topkey => merge(topvalue, {
#     resource_group_name = data.azurerm_resource_group.sb_rg.name
#     scopes              = [data.azurerm_servicebus_namespace.sb.id]
#     criteria = { for ck, cval in topvalue.criteria : ck => merge(cval, {
#       dimension_values = [for i, q in azurerm_servicebus_queue.default : q.id if i < 5]
#       })
#     }
#     })
#   }
# }

module "under_test" {
  source                   = "../../"
  tags              = module.default_label.tags
  alert_description = "description here %s"
  alert_name_prefix        = module.default_label.id
  metric_alert = {
    "service1dlq_critical" = {
      criteria = {
        entity_name_include = {
          # aggregation = "value"
          dimension_name     = "EntityName"
          dimension_operator = "Include"
          dimension_values   = [for i, q in azurerm_servicebus_queue.default : q.id if i < 5]
          metric_name        = "DeadletteredMessages"
          metric_namespace   = "Microsoft.ServiceBus/namespaces"
          operator           = "GreaterThan"
          threshold          = 10
          aggregation        = "Average"
        }
      }
      description = "add me to base"
      enabled     = true
      # frequency = "value
      resource_group_name = azurerm_resource_group.default["main"].name
      scopes              = [azurerm_servicebus_namespace.default.id]
      severity            = 0
      tags = {
        "Service" = "service1"
      }
      action_map = {} //, noncritical: {email_address: "foo@test.com"}}
      # target_resource_location = "value
      # window_size = "value"
    }
    "server_error" = {
      criteria = {
        server_error_send_latency = {
          dimension_name     = ""
          # dimension_operator = "Include"
          dimension_values   = [] 
          metric_name        = "ServerSendLatency"
          metric_namespace   = "Microsoft.ServiceBus/namespaces"
          operator           = "GreaterThan"
          threshold          = 10
          aggregation        = "Average"
        }
      }
      description = "add me to server latency"
      enabled     = true
      # frequency = "value
      resource_group_name = azurerm_resource_group.default["main"].name
      scopes              = [azurerm_servicebus_namespace.default.id]
      severity            = 0
      tags = {
        "Service" = "service1"
      }
      action_map = {} //, noncritical: {email_address: "foo@test.com"}}
      # target_resource_location = "value
      # window_size = "value"
    }
  }
  action_group = {
    "key" = {
      email_receiver = {
        "key" = {
          email_address = "foo@bar.com"
          use_common_alert_schema = false
        }
      }
      enabled = true
      resource_group_name = azurerm_resource_group.default["main"].name
      short_name = "value"
    }
  }
}

output "monitor_metric_alert" {
  description = "Metric alert map"
  value       = module.under_test.monitor_metric_alert
}

output "metric_action_group" {
  description = "Metric action group"
  value       = module.under_test.metric_action_group
}
