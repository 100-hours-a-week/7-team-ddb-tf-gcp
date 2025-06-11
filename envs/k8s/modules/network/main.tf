resource "google_compute_network" "vpc" {
  name                    = "vpc-${var.env}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnets" {
  for_each = var.subnets

  name                     = "subnet-${each.key}-${var.env}"
  ip_cidr_range            = each.value.cidr
  network                  = google_compute_network.vpc.id
  private_ip_google_access = false

  dynamic "secondary_ip_range" {
    for_each = lookup(each.value, "secondary_ranges", {})
    content {
      range_name    = secondary_ip_range.key
      ip_cidr_range = secondary_ip_range.value
    }
  }
}