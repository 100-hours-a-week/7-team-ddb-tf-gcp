# be instance가 사용할 ssh key 생성 및 secret manager에 저장
resource "tls_private_key" "be" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_secret_manager_secret" "be_ssh_key" {
  secret_id = "be-ssh-key-${var.env}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "be_ssh_key_version" {
  secret         = google_secret_manager_secret.be_ssh_key.id
  secret_data_wo = tls_private_key.be.private_key_pem
}

data "tls_public_key" "be" {
  private_key_pem = tls_private_key.be.private_key_pem
}

locals {
  ssh_key_entries = [
    for u in var.ssh_users :
    "${u}:${data.tls_public_key.be.public_key_openssh}"
  ]
  be_tag = "be"
}

// be instance 생성
resource "google_compute_instance" "be" {
  name         = "be-instance-${var.env}"
  machine_type = var.machine_type
  zone         = var.zone

  tags = [
    local.be_tag,
    var.private_route_tag
  ]

  labels = {
    name        = "be-instance-${var.env}"
    component   = "be"
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
  }

  metadata = {
    ssh-keys = join("\n", local.ssh_key_entries)
  }
  metadata_startup_script = file("${path.module}/scripts/startup.sh")
}

// be instance의 방화벽
resource "google_compute_firewall" "bastion_to_be" {
  name      = "bastion-to-be-firewall-${var.env}"
  network   = var.network
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_tags = [var.bastion_tag]
  target_tags = [local.be_tag]
}

// be instance의 방화벽
resource "google_compute_firewall" "lb_to_be" {
  name      = "lb-to-be-firewall-${var.env}"
  network   = var.network
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = [tostring(var.be_port)]
  }
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16",
  ]
  target_tags = [local.be_tag]
}

resource "google_compute_firewall" "be_to_cloudsql_public" {
  name    = "cloudsql-to-be-firewall-${var.env}"
  network = var.network
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_tags        = [local.be_tag]
  destination_ranges = [var.cloudsql_ip_address]
}

# BE 인스턴스 묶을 인스턴스 그룹 (Named Port 설정)
resource "google_compute_instance_group" "be_group" {
  name = "be-ig-${var.env}"
  zone = var.zone
  instances = [
    google_compute_instance.be.self_link
  ]

  named_port {
    name = var.ig_port_name
    port = var.be_port
  }
}

# 헬스체크 
resource "google_compute_health_check" "be_hc" {
  name = "be-hc-${var.env}"

  http_health_check {
    port         = var.be_port
    request_path = var.be_health_check_path
  }
}
