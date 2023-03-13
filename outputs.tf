
output "monitor_metric_alert" {
  description = "Metric alert map"
  value       = { for k, v in azurerm_monitor_metric_alert.default : k => { id : v.id, name : v.name } }
}

output "metric_action_group" {
  description = "Metric action group"
  value       = { for k, v in azurerm_monitor_action_group.default : k => { id : v.id, name : v.name } }
}
