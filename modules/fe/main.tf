# FE 서비스 계정 생성 및 권한 부여
resource "google_service_account" "fe" {
  account_id   = "frontend-${var.env}"
  display_name = "Frontend Service Account"
  project      = var.project_id
}

# FE 서비스 계정 키 발급
resource "google_service_account_key" "fe_key" {
  service_account_id = google_service_account.fe.name
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
}

# FE 서비스 계정 키를 저장할 Secret Manager 비밀 생성
resource "google_secret_manager_secret" "fe_sa_key_secret" {
  secret_id = "fe-sa-key-${var.env}"

  replication {
    auto {}
  }
}

# FE 서비스 계정 키 값을 Secret Manager에 저장
resource "google_secret_manager_secret_version" "fe_sa_key_version" {
  secret      = google_secret_manager_secret.fe_sa_key_secret.id
  secret_data = base64decode(google_service_account_key.fe_key.private_key)
}

# FE 서비스 계정이 자신의 비밀 값을 읽을 수 있도록 권한 부여
resource "google_secret_manager_secret_iam_member" "fe_key_secret_access" {
  secret_id = google_secret_manager_secret.fe_sa_key_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.fe.email}"

  depends_on = [google_service_account.fe]
}

# Secret Manager에서 jenkins 공개키 조회 권한 부여
resource "google_secret_manager_secret_iam_member" "fe_secret_access_to_jenkins_key" {
  secret_id = "projects/${var.project_id}/secrets/jenkins-ssh-key-shared"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.fe.email}"

  depends_on = [google_service_account.fe]
}

# Artifact Registry 읽기 권한 부여
resource "google_project_iam_member" "fe_artifact_registry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.fe.email}"

  depends_on = [google_service_account.fe]
}

# Jenkins 공개키를 FE가 사용하기 위한 설정
data "google_secret_manager_secret_version" "jenkins_pubkey" {
  secret = "jenkins-ssh-key-shared"
  version = "latest"
  depends_on = [google_secret_manager_secret_iam_member.fe_secret_access_to_jenkins_key]
}

data "tls_public_key" "jenkins_pubkey" {
  private_key_pem = data.google_secret_manager_secret_version.jenkins_pubkey.secret_data
}

# SSH 키 조합
locals {
  fe_tag = "fe" 

  ssh_key_entries = [ for user in var.ssh_users : "${user}:${data.tls_public_key.jenkins_pubkey.public_key_openssh}" ]

  dockercompose_content = file("${path.module}/files/docker-compose.yml")
  rendered_startup_script = templatefile("${path.module}/scripts/startup.sh", {
    name                  = "monitoring"
    dockercompose_content = local.dockercompose_content
  })
}

# FE 인스턴스 생성
resource "google_compute_instance" "fe" {
  name         = "fe-instance-${var.env}"
  machine_type = var.machine_type
  zone         = var.zone

  allow_stopping_for_update = true

  service_account {
    email  = google_service_account.fe.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
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
    ENV_LABEL = var.env
  }

  metadata_startup_script = local.rendered_startup_script

  tags = [local.fe_tag, var.private_route_tag]

  labels = {
    name        = "fe-instance-${var.env}"
    environment = var.env
    component   = "fe" 
    managed_by  = "terraform"
  }

  depends_on = [
    google_service_account.fe,
    google_service_account_key.fe_key,
    google_secret_manager_secret_version.fe_sa_key_version,
    google_secret_manager_secret_iam_member.fe_key_secret_access,
    google_secret_manager_secret_iam_member.fe_secret_access_to_jenkins_key
  ]
}

# bastion에서 FE 인스턴스로 SSH 접속 허용 
resource "google_compute_firewall" "ssh_from_shared_to_fe" {
  name      = "ssh-from-shared-to-fe-${var.env}"
  network   = var.network
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22", "9100"]
  }

  source_ranges = [var.shared_vpc_cidr]  
  target_tags   = [local.fe_tag]
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