resource "google_compute_network" "vpc" {
  name                    = "vpc-${var.env}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnets" {
  for_each = var.subnets

  name                     = each.key
  ip_cidr_range            = each.value.cidr
  network                  = google_compute_network.vpc.id
  private_ip_google_access = false
}

resource "google_compute_route" "public_route" {
  name             = "public-route"
  network          = google_compute_network.vpc.name
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
  tags             = [var.public_route_tag]
}

resource "google_compute_route" "private_route" {
  name              = "private-route"
  network           = google_compute_network.vpc.name
  dest_range        = "0.0.0.0/0"
  next_hop_instance = var.nat_link
  priority          = 1000
  tags              = [var.private_route_tag]
}
