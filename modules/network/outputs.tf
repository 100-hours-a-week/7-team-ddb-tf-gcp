output "vpc_self_link" {
  description = "The self_link of the VPC network"
  value       = google_compute_network.vpc.self_link
}

output "subnet_self_links" {
  description = "각 subnet의 self_link를 key=name으로 반환"
  value = {
    for k, subnet in google_compute_subnetwork.subnets :
    k => subnet.self_link
  }
}