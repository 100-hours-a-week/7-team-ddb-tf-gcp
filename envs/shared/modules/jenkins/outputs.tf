output "jenkins_public_key" {
  description = "jenkins public key"
  value       = data.tls_public_key.jenkins_ssh_pubkey.public_key_openssh
}
output "jenkins_group" {
  description = "SelfLink of BE instance group"
  value       = google_compute_instance_group.jenkins_group.self_link
}

output "health_check" {
  description = "ID of BE health check"
  value       = google_compute_health_check.health_check.self_link
}