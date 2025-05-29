# k6 SSH 키 생성
resource "tls_private_key" "k6_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "tls_public_key" "k6_ssh_pubkey" {
  private_key_pem = tls_private_key.k6_ssh.private_key_pem
}

# 비공개 키를 Secret Manager에 저장
resource "google_secret_manager_secret" "k6_ssh_key" {
  secret_id = "k6-ssh-key-${var.env}"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "k6_ssh_key_version" {
  secret      = google_secret_manager_secret.k6_ssh_key.id
  secret_data = tls_private_key.k6_ssh.private_key_pem
}

locals {
  metadata_startup_script = file("${path.module}/scripts/startup.sh")

  ssh_key_entries = [
    for user in var.ssh_users :
    "${user}:${data.tls_public_key.k6_ssh_pubkey.public_key_openssh}"
  ]

  k6_priv_key_b64  = base64encode(tls_private_key.k6_ssh.private_key_pem)
}

resource "google_compute_instance" "k6_instance" {
  name         = "k6-${var.env}"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20250425"
      size  = 20
    }
  }

  network_interface {
    network       = var.network
    subnetwork    = var.subnetwork
    network_ip    = "10.40.10.2"
    access_config {}  
  }

  metadata = {
    ssh-keys       = join("\n", local.ssh_key_entries)
    startup-script = local.metadata_startup_script
  }

  tags = [var.instance_tag]

  labels = {
    name       = "k6-instance"
    env        = var.env
    managed_by = "terraform"
  }
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-k6"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = [var.instance_tag]
  source_ranges = ["0.0.0.0/0"]
}