output "k6_instance_ip" {
  value = google_compute_instance.k6_instance.network_interface[0].access_config[0].nat_ip
}