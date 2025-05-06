# FE 인스턴스를 위한 SSH 키 페어 생성 
resource "tls_private_key" "fe_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "tls_public_key" "fe_ssh_pubkey" {
  private_key_pem = tls_private_key.fe_ssh_key.private_key_pem
}

# 비공개 키를 Secret Manager에 저장
resource "google_secret_manager_secret" "fe_ssh_key" {
  secret_id = "fe-ssh-key-${var.env}"

  replication {
    auto {}  
  }
}

resource "google_secret_manager_secret_version" "fe_ssh_key_ver" {
  secret      = google_secret_manager_secret.fe_ssh_key.id
  secret_data = tls_private_key.fe_ssh_key.private_key_pem
}

locals {
  fe_tag = "fe" 

  ssh_key_entries = [
    for user in var.ssh_users :
    "${user}:${data.tls_public_key.fe_ssh_pubkey.public_key_openssh}"
  ] 
}

# FE 인스턴스 생성
resource "google_compute_instance" "fe" {
  name         = "fe-instance-${var.env}"
  machine_type = var.machine_type
  zone         = var.zone

  tags = [local.fe_tag, var.private_route_tag]

  labels = {
    name        = "fe-instance-${var.env}"
    environment = var.env
    component   = "fe" 
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

# bastion에서 FE 인스턴스로 SSH 접속 허용 
resource "google_compute_firewall" "bastion_to_fe" {
  name      = "bastion-to-fe-${var.env}"
  network   = var.network
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = [var.bastion_tag]
  target_tags = [local.fe_tag]
}

# GCP 로드밸런서에서 FE 인스턴스의 앱 포트로 접근 허용
resource "google_compute_firewall" "lb_to_fe" {
  name      = "lb-to-fe-${var.env}"
  network   = var.network
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = [tostring(var.fe_port)]
  }

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  target_tags = [local.fe_tag]
}

resource "google_compute_instance_group" "fe_group" {
  name      = "fe-group-${var.env}"
  zone      = var.zone
  instances = [google_compute_instance.fe.self_link]

  named_port {
    name = var.ig_port_name
    port = var.fe_port
  }
}

resource "google_compute_health_check" "fe" {
  name = "fe-health-check-${var.env}"

  http_health_check {
    port         = var.fe_port
    request_path = var.health_check_path 
  }
}