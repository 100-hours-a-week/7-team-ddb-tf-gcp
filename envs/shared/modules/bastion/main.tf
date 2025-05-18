# Bastion instance가 사용할 고정 ip address
resource "google_compute_address" "bastion" {
  name = "bastion-ip-${var.env}"
}

# bastion instance가 사용할 ssh key 생성 및 secret manager에 저장
resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "tls_public_key" "bastion" {
  private_key_pem = tls_private_key.bastion.private_key_pem
}

resource "google_secret_manager_secret" "bastion_ssh_key" {
  secret_id = "bastion-ssh-key-${var.env}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "bastion_ssh_key_version" {
  secret      = google_secret_manager_secret.bastion_ssh_key.id
  secret_data = tls_private_key.bastion.private_key_pem
}

locals {
  ssh_key_entries = [
    for u in var.ssh_users :
    "${u}:${data.tls_public_key.bastion.public_key_openssh}"
  ]
  bastion_tag = "bastion"
}

// Bastion instance 생성
resource "google_compute_instance" "bastion" {
  name         = "bastion-${var.env}"
  machine_type = var.machine_type
  zone         = var.zone

  tags = [
    local.bastion_tag,
    var.public_route_tag
  ]

  labels = {
    name        = "bastion-isntance-${var.env}"
    component   = "bastion"
    environment = var.env
    managed_by  = "terraform"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20250425"
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork


    access_config {
      nat_ip = google_compute_address.bastion.address
    }
  }

  metadata = {
    ssh-keys = join("\n", local.ssh_key_entries)
  }
}

// bastion instance의 방화벽
resource "google_compute_firewall" "bastion_ssh" {
  name      = "bastion-ssh-${var.env}"
  network   = var.network
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allowed_ssh_cidrs
  target_tags   = [local.bastion_tag]
}