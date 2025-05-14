resource "google_compute_network_peering" "this_to_peer" {
  name         = "${var.name_prefix}-to-${var.peer_name}"
  network      = var.this_vpc_self_link
  peer_network = var.peer_vpc_self_link

  export_custom_routes = var.export_custom_routes
  import_custom_routes = var.import_custom_routes
}

resource "google_compute_network_peering" "peer_to_this" {
  name         = "${var.peer_name}-to-${var.name_prefix}"
  network      = var.peer_vpc_self_link
  peer_network = var.this_vpc_self_link

  export_custom_routes = var.peer_export_custom_routes
  import_custom_routes = var.peer_import_custom_routes
}
