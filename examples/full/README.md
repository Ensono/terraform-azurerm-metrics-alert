# Azure Metrics example

[test.tf](./test.tf)

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
| mod_under_test_multiple_alerts | ../../ |  |

## Resources

| Name |
|------|
| [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) |
| [azurerm_servicebus_namespace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace) |
| [azurerm_servicebus_queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue) |

## Inputs

No input.

## Outputs

No output.
