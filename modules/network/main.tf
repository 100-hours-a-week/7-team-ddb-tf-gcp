resource "google_compute_network" "vpc" {
  name                    = "vpc-${var.env}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnets" {
  for_each = var.subnets

  name          = each.key
  ip_cidr_range = each.value.cidr
  network       = google_compute_network.vpc.id
  region        = var.region
  private_ip_google_access = contains(["private"], each.value.type)
}