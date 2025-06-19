resource "google_compute_instance" "influxdb" {
  name         = "influxdb"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20250425"
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
    network_ip    = "10.40.10.3"
    access_config {}
  }

  metadata = {
    startup-script = local.metadata_startup_script
  }

  tags = ["influxdb"]
}

resource "google_compute_firewall" "allow_influxdb_8086" {
  name    = "allow-influxdb-8086"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["8086"]
  }

  target_tags   = ["influxdb"]
  source_ranges = ["0.0.0.0/0"] 
}

locals {
  metadata_startup_script = file("${path.module}/scripts/startup.sh")
}