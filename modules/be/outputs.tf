output "instance_group" {
  description = "SelfLink of BE instance group"
  value       = google_compute_instance_group.be_group.self_link
}

output "health_check" {
  description = "ID of BE health check"
  value       = google_compute_health_check.be_hc.self_link
}

output "port_name" {
  description = "Named port key for BE"
  value       = var.ig_port_name
}

output "service_account_email" {
  value = google_service_account.be.email
}