# BE 서비스 계정 생성 및 권한 부여
resource "google_service_account" "be" {
  account_id   = "backend2"
  display_name = "backend Service Account"
  project      = var.project_id
}

# 서비스 계정 키 생성
resource "google_service_account_key" "be_key" {
  service_account_id = google_service_account.be.name
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
}

# Secret Manager에 키 저장
resource "google_secret_manager_secret" "be_sa_key_secret" {
  secret_id = "be-sa-key-${var.env}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "be_sa_key_version" {
  secret      = google_secret_manager_secret.be_sa_key_secret.id
  secret_data_wo = base64decode(google_service_account_key.be_key.private_key)
}

# Secret Manager에서 jenkins 공개키 조회 권한 부여
resource "google_secret_manager_secret_iam_member" "be_secret_access_to_jenkins_key" {
  secret_id = "projects/${var.project_id}/secrets/jenkins-ssh-key-shared"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.be.email}"

  depends_on = [google_service_account.be]
}

# Secret 접근 권한 부여 (BE 인스턴스가 자기 키를 가져갈 수 있도록)
resource "google_secret_manager_secret_iam_member" "be_key_secret_access" {
  secret_id = google_secret_manager_secret.be_sa_key_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.be.email}"

  depends_on = [google_service_account.be]
}

# Artifact Registry 읽기 권한 부여
resource "google_project_iam_member" "be_artifact_registry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.be.email}"

  depends_on = [google_service_account.be]
}

# Jenkins 공개키를 BE가 사용하기 위한 설정
data "google_secret_manager_secret_version" "jenkins_pubkey" {
  secret = "jenkins-ssh-key-shared"
  version = "latest"
  depends_on = [google_secret_manager_secret_iam_member.be_secret_access_to_jenkins_key]
}

data "tls_public_key" "jenkins_pubkey" {
  private_key_pem = data.google_secret_manager_secret_version.jenkins_pubkey.secret_data
}

locals {
  be_tag = "be" 

  ssh_key_entries = [ for user in var.ssh_users : "${user}:${data.tls_public_key.jenkins_pubkey.public_key_openssh}" ]
}

// be instance 생성
resource "google_compute_instance" "be" {
  name         = "be-instance-${var.env}"
  machine_type = var.machine_type
  zone         = var.zone

  service_account {
    email  = google_service_account.be.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

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
    ENV_LABEL = var.env
  }

  metadata_startup_script = file("${path.module}/scripts/startup.sh")

  depends_on = [
    google_service_account.be,
    google_service_account_key.be_key,
    google_secret_manager_secret_version.be_sa_key_version,
    google_secret_manager_secret_iam_member.be_key_secret_access,
    google_secret_manager_secret_iam_member.be_secret_access_to_jenkins_key
  ]
}

// be instance의 방화벽
resource "google_compute_firewall" "ssh_from_shared_to_be" {
  name      = "ssh-from-shared-to-be-${var.env}"
  network   = var.network
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22", "9100", "8081"]
  }

  source_ranges = [var.shared_vpc_cidr]  
  target_tags   = [local.be_tag]
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
  target_tags   = [local.be_tag]
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
