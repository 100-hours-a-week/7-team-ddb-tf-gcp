# AI 서비스 계정 생성 및 권한 부여
resource "google_service_account" "ai" {
  account_id   = "ai-service"
  display_name = "ai Service Account"
  project      = var.project_id
}

resource "google_service_account_key" "ai_key" {
  service_account_id = google_service_account.ai.name
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
}

resource "google_secret_manager_secret" "ai_sa_key_secret" {
  secret_id = "ai-sa-key-${var.env}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "ai_sa_key_version" {
  secret      = google_secret_manager_secret.ai_sa_key_secret.id
  secret_data = base64decode(google_service_account_key.ai_key.private_key)
}

resource "google_secret_manager_secret_iam_member" "ai_key_secret_access" {
  secret_id = google_secret_manager_secret.ai_sa_key_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.ai.email}"

  depends_on = [google_service_account.ai]
}

# Secret Manager에서 jenkins 공개키 조회 권한 부여
resource "google_secret_manager_secret_iam_member" "ai_secret_access_to_jenkins_key" {
  secret_id = "projects/${var.project_id}/secrets/jenkins-ssh-key-shared"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.ai.email}"

  depends_on = [google_service_account.ai]
}

# Artifact Registry 읽기 권한 부여
resource "google_project_iam_member" "ai_artifact_registry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.ai.email}"

  depends_on = [google_service_account.ai]
}

# Jenkins 공개키를 AI가 사용하기 위한 설정
data "google_secret_manager_secret_version" "jenkins_pubkey" {
  secret = "jenkins-ssh-key-shared"
  version = "latest"
  depends_on = [google_secret_manager_secret_iam_member.ai_secret_access_to_jenkins_key]
}

data "tls_public_key" "jenkins_pubkey" {
  private_key_pem = data.google_secret_manager_secret_version.jenkins_pubkey.secret_data
}

locals {
  ai_tag = "ai"

  ssh_key_entries = [ for user in var.ssh_users : "${user}:${data.tls_public_key.jenkins_pubkey.public_key_openssh}" ]
}

# FastAPI 백엔드 인스턴스
resource "google_compute_instance" "ai" {
  name         = "ai-instance-${var.env}"
  machine_type = var.machine_type
  zone         = var.zone

  service_account {
    email  = google_service_account.ai.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

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
      size  = 20
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
  }

  metadata = {
    ssh-keys = join("\n", local.ssh_key_entries)
    ENV_LABEL = var.env
  }
  allow_stopping_for_update = true
  metadata_startup_script = file("${path.module}/scripts/startup.sh")

  depends_on = [
    google_service_account.ai,
    google_service_account_key.ai_key,
    google_secret_manager_secret_version.ai_sa_key_version,
    google_secret_manager_secret_iam_member.ai_key_secret_access,
    google_secret_manager_secret_iam_member.ai_secret_access_to_jenkins_key
  ]
}

# bastion에서 ai로의 SSH 접속 허용
resource "google_compute_firewall" "ssh_from_shared_to_ai" {
  name      = "ssh-from-shared-to-ai-${var.env}"
  network   = var.network
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [var.shared_vpc_cidr]  
  target_tags   = [local.ai_tag]
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