# terraform-azurerm-metrics-alert

Metrics alerts for Azure

Currently excludes dynamic threshold

## Test

To run tests `make test` - prerequisites Go1.19

See an [example](./examples/full/README.md)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.14 |
| azuread | >= 1.5.0 |
| azurerm | >= 2.99.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 2.99.0 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [azurerm_monitor_action_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group) |
| [azurerm_monitor_metric_alert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| action\_group | Action groups definitions when the module will create alert action groups for you | <pre>map(object({ resource_group_name = string<br>    short_name = string<br>    enabled    = bool<br>    email_receiver = map(object({<br>      email_address           = string<br>      use_common_alert_schema = bool<br>    }))<br>  }))</pre> | `{}` | no |
| action\_name\_prefix | Prefix for the action group to specify | `string` | `""` | no |
| alert\_description | shared description prefix for all alerts. use fmt.Sprintf() format | `string` | `""` | no |
| alert\_name\_prefix | prefix for all alert names | `string` | n/a | yes |
| metric\_alert | Input map to create alerts based on metric, for more information about metric alerts https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-types#metric-alerts | <pre>map(object({<br>    resource_group_name      = string<br>    scopes                   = list(string)<br>    frequency                = optional(string, "PT5M")<br>    enabled                  = optional(bool, true)<br>    description              = string<br>    severity                 = optional(number, 3)<br>    tags                     = optional(map(string), any)<br>    window_size              = optional(string, "PT5M")<br>    target_resource_location = optional(string, null)<br>    criteria = map(object({<br>      metric_namespace   = string,<br>      metric_name        = string,<br>      aggregation        = optional(string, "Average"),<br>      operator           = optional(string, "GreaterThan")<br>      threshold          = number<br>      dimension_name     = string //"EntityName"<br>      dimension_operator = string<br>      dimension_values   = list(string)<br>    }))<br>    action_map = map(object({ webhook_properties = optional(any, null), action_group_id = string })) <br>  }))</pre> | `{}` | no |
| tags | common set of tags to apply to all alerts | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| metric\_action\_group | Metric alert map |
| monitor\_metric\_alert | Metric alert map |
