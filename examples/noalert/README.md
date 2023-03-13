# No Alert example

Create alarms but skip alerts

## Requirements

| Name | Version |
|------|---------|
| azuread | 1.5.0 |
| azurerm | ~> 2.99.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 2.99.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| default_label | git::https://github.com/cloudposse/terraform-null-label.git?ref=0.24.1 |  |
| under_test | ../../ |  |

## Resources

| Name |
|------|
| [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) |
| [azurerm_servicebus_namespace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace) |
| [azurerm_servicebus_queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | (optional) describe your variable | `string` | `"dn.metrics"` | no |

## Outputs

| Name | Description |
|------|-------------|
| metric\_action\_group | Metric action group |
| monitor\_metric\_alert | Metric alert map |
