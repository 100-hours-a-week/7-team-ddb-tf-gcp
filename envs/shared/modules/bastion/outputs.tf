output "instance_self_link" {
  description = "Bastion instance의 self_link"
  value       = google_compute_instance.bastion.self_link
}

output "bastion_ip" {
  description = " Bastion instance의 ip"
  value       = google_compute_address.bastion.address
}

output "bastion_tag" {
  description = "bastion의 태그"
  value = local.bastion_tag
}