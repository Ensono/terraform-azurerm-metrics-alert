variable "metric_alert" {
  type = map(object({
    resource_group_name      = string
    scopes                   = list(string)
    frequency                = optional(string, "PT5M")
    enabled                  = optional(bool, true)
    description              = string
    severity                 = optional(number, 3)
    tags                     = optional(map(string), any)
    window_size              = optional(string, "PT5M")
    target_resource_location = optional(string, null)
    criteria = map(object({
      metric_namespace   = string,
      metric_name        = string,
      aggregation        = optional(string, "Average"),
      operator           = optional(string, "GreaterThan")
      threshold          = number
      dimension_name     = string // pass "" empty string to skip this
      dimension_operator = optional(string, "")
      dimension_values   = optional(list(string), [])
    }))
    action_map = map(object({ webhook_properties = optional(any, null), action_group_id = string }))
  }))
  default     = {}
  description = "Input map to create alerts based on metric, for more information about metric alerts https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-types#metric-alerts"
  validation {
    condition     = alltrue(flatten([for k, v in var.metric_alert : [for i, j in v.criteria : length(try(v.criteria[i], {})) > 0]]))
    error_message = "Must contain at least one criteria block."
  }
  validation {
    condition = alltrue(flatten([for k, v in var.metric_alert : [for i, j in v.criteria : lookup(v.criteria[i], "dimension_name", "") != "" ?
      # only fail if dimenion_name is provided and values are empty else skip validation
      # as dimension is not required
    (length(try(v.criteria[i].dimension_values, [])) > 0 ? true : false) : true]]))
    error_message = "Must include at least one value for dimension in a criteria block."
  }
  validation {
    condition     = alltrue([for k, v in var.metric_alert : length(try(v.description, {})) > 0])
    error_message = "Description must be provided."
  }
  validation {
    condition     = alltrue([for k, v in var.metric_alert : length(try(v.resource_group_name, "")) > 0])
    error_message = "Resource Group name must be provided in the alert object."
  }
  validation {
    condition     = alltrue([for k, v in var.metric_alert : length(try(v.scopes, [])) > 0])
    error_message = "At least one scope must be specified."
  }
}

# variable "action_map" {
#     type = map(object({ webhook_properties = optional(any, null), action_group_id = string })) 
#   description = "map of action receivers to notify"
# }

variable "alert_name_prefix" {
  type        = string
  description = "prefix for all alert names"
}

variable "alert_description" {
  type        = string
  default     = ""
  description = "shared description prefix for all alerts. use fmt.Sprintf() format "
}

variable "tags" {
  type        = map(string)
  description = "common set of tags to apply to all alerts"
  default     = {}
}

variable "action_group" {
  type = map(object({ resource_group_name = string
    short_name = string
    enabled    = bool
    email_receiver = map(object({
      email_address           = string
      use_common_alert_schema = bool
    }))
  }))
  default     = {}
  description = "Action groups definitions when the module will create alert action groups for you"
}

variable "action_name_prefix" {
  type        = string
  default     = ""
  description = "Prefix for the action group to specify"
}
