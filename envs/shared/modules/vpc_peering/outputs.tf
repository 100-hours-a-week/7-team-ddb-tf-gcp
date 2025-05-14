output "this_to_peer_name" {
  value = google_compute_network_peering.this_to_peer.name
}

output "peer_to_this_name" {
  value = google_compute_network_peering.peer_to_this.name
}
