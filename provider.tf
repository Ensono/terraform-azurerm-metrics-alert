terraform {
  required_version = ">= 0.14"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 1.5.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.99.0"
    }
  }
  # enabled due to 0.14+ support
  experiments = [module_variable_optional_attrs]
}
