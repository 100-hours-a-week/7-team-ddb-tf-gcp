# SSH 키 페어 생성
resource "tls_private_key" "ai_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "tls_public_key" "ai_ssh_pubkey" {
  private_key_pem = tls_private_key.ai_ssh_key.private_key_pem
}

# 비공개 키를 Secret Manager에 저장
resource "google_secret_manager_secret" "ai_ssh_key" {
  secret_id = "ai-ssh-key-${var.env}"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "ai_ssh_key_ver" {
  secret      = google_secret_manager_secret.ai_ssh_key.id
  secret_data = tls_private_key.ai_ssh_key.private_key_pem
}

locals {
  ai_tag = "ai"

  ssh_key_entries = [
    for user in var.ssh_users :
    "${user}:${data.tls_public_key.ai_ssh_pubkey.public_key_openssh}"
  ]
}

# FastAPI 백엔드 인스턴스
resource "google_compute_instance" "ai" {
  name         = "ai-instance-${var.env}"
  machine_type = var.machine_type
  zone         = var.zone

  tags = [local.ai_tag, var.private_route_tag]

  labels = {
    name        = "ai-instance-${var.env}"
    environment = var.env
    component   = "ai"
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

# bastion에서 ai로의 SSH 접속 허용
resource "google_compute_firewall" "bastion_to_ai" {
  name      = "bastion-to-ai-${var.env}"
  network   = var.network
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = [var.bastion_tag]
  target_tags = [local.ai_tag]
}

# 로드밸런서에서 FastAPI 앱 포트로의 접근 허용
resource "google_compute_firewall" "lb_to_ai" {
  name      = "lb-to-ai-${var.env}"
  network   = var.network
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = [tostring(var.ai_port)]
  }

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  target_tags = [local.ai_tag]
}

resource "google_compute_instance_group" "ai_group" {
  name      = "ai-group-${var.env}"
  zone      = var.zone
  instances = [google_compute_instance.ai.self_link]

  named_port {
    name = var.ai_port_name
    port = var.ai_port
  }
}

resource "google_compute_health_check" "ai" {
  name = "ai-health-check-${var.env}"

  http_health_check {
    port         = var.ai_port
    request_path = var.health_check_path 
  }
}