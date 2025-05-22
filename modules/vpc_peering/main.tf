resource "google_compute_network_peering" "vpc_peering" {
  name         = "${var.name_prefix}-to-${var.peer_name}"
  network      = var.this_vpc_self_link
  peer_network = var.peer_vpc_self_link

  export_custom_routes = var.export_custom_routes
  import_custom_routes = var.import_custom_routes
}

resource "google_compute_firewall" "peer_firewall" {
  count   = var.create_firewall ? 1 : 0
  name    = "allow-peer-${var.name_prefix}-to-${var.peer_name}"
  network = var.this_vpc_self_link

  direction     = "INGRESS"
  source_ranges = var.peer_cidr_blocks
  target_tags   = var.firewall_target_tags

  allow {
    protocol = "tcp"
    ports    = var.allowed_ports
  }

  allow {
    protocol = "icmp"
  }

  description = "Allow traffic from peered VPC (${var.peer_name})"
}
