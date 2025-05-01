output "vpc_self_link" {
  description = "The self_link of the VPC network"
  value       = google_compute_network.vpc.self_link
}