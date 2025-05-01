output "instance_self_link" {
  description = "NAT_Bastion instance의 self_link"
  value       = google_compute_instance.nat_bastion.self_link
}

output "nat_ip" {
  description = " NAT_Bastion instance의 ip"
  value       = google_compute_address.nat_bastion_ip.address
}
