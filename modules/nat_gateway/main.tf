resource "google_compute_address" "nat_ip" {
  name   = "nat-ip-${var.env}"
  address_type = "EXTERNAL"
}

resource "google_compute_router" "nat_router" {
  name    = "nat-router-${var.env}"
  network = var.vpc_self_link
}

resource "google_compute_router_nat" "nat_gw" {
  name                               = "cloud-nat-${var.env}"
  router                             = google_compute_router.nat_router.name
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat_ip.self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  enable_dynamic_port_allocation = true
  min_ports_per_vm               = 64

  auto_network_tier = "STANDARD"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

  lifecycle {
    create_before_destroy = true
  }
}