output "serverless_gateway_urls" {
  description = "Per-student Konnect Serverless Gateway proxy URLs. Distribute as $PROXY to each student."
  value = {
    for student_id in local.student_ids :
    student_id => "${split(".", konnect_gateway_control_plane.serverless_cp[student_id].config.control_plane_endpoint)[0]}.us.serverless.gateways.konggateway.com"
  }
}

# output "agent_api_keys" {
#   description = "Per-student API keys for the expense-agent consumer. Distribute as $AGENT_API_KEY (Lab 2+). Marked sensitive — use 'terraform output -json agent_api_keys' to retrieve."
#   sensitive   = true
#   value = {
#     for id in local.student_ids :
#     "${var.student_name_prefix}${id}" => konnect_gateway_consumer_key_auth.expense_agent_key[id].key
#   }
# }

output "system_account_access_token" {
  description = "The generated system account access token"
  sensitive   = true
  value       = konnect_system_account_access_token.token.token
}

output "kafka_bootstrap_servers" {
  description = "Kafka bootstrap server for Lab 4. Empty string if Lab 4 is not being run."
  value       = var.kafka_bootstrap_servers != "" ? var.kafka_bootstrap_servers : "(not configured — Lab 4 skipped)"
}

output "control_plane_ids" {
  description = "Per-student control plane IDs. Useful for scoping decK syncs with --konnect-control-plane-name."
  value = {
    for id in local.student_ids :
    "${var.student_name_prefix}${id}" => konnect_gateway_control_plane.serverless_cp[id].id
  }
}

output "vault_ids" {
  description = "Map of student IDs to their vault IDs"
  value = {
    for student_id in local.student_ids : student_id => konnect_gateway_vault.student_vault[student_id].id
  }
}

output "config_store_ids" {
  description = "Per-student Config Store IDs. Needed if you want to add secrets to the store after apply."
  value = {
    for id in local.student_ids :
    "${var.student_name_prefix}${id}" => konnect_gateway_config_store.student_config_store[id].id
  }
}
