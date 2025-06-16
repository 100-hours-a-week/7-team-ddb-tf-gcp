# Jenkins SSH 키 생성
resource "tls_private_key" "jenkins_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "tls_public_key" "jenkins_ssh_pubkey" {
  private_key_pem = tls_private_key.jenkins_ssh.private_key_pem
}

# 비공개 키를 Secret Manager에 저장
resource "google_secret_manager_secret" "jenkins_ssh_key" {
  secret_id = "jenkins-ssh-key-${var.env}"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "jenkins_ssh_key_version" {
  secret      = google_secret_manager_secret.jenkins_ssh_key.id
  secret_data = tls_private_key.jenkins_ssh.private_key_pem
}

# Jenkins VM SSH 키 및 startup script 구성
locals {
  jenkins_tag = "jenkins"

  ssh_key_entries = [
    for user in var.ssh_users :
    "${user}:${data.tls_public_key.jenkins_ssh_pubkey.public_key_openssh}"
  ]

  jenkins_dockerfile_content = file("${path.module}/scripts/Dockerfile.jenkins")
  dockercompose_content      = file("${path.module}/files/docker-compose.yml")

  rendered_startup_script = templatefile("${path.module}/scripts/startup.sh", {
    name                     = "jenkins"
    jenkins_priv_key_b64  = base64encode(tls_private_key.jenkins_ssh.private_key_pem)
    dockerfile_content       = local.jenkins_dockerfile_content
    dockercompose_content = local.dockercompose_content
  })
}

# Jenkins용 서비스 계정 생성
resource "google_service_account" "jenkins" {
  account_id   = "jenkins"
  display_name = "Jenkins Service Account"
  project      = var.project_id
}

# Secret Manager 접근 권한 부여
resource "google_project_iam_member" "jenkins_secret_access" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.jenkins.email}"

  depends_on = [google_service_account.jenkins]
}

# Artifact Registry 쓰기 권한 부여
resource "google_project_iam_member" "jenkins_artifact_registry_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.jenkins.email}"

  depends_on = [google_service_account.jenkins]
}

# GCS 버킷에 대한 objectAdmin 권한 부여
resource "google_storage_bucket_iam_member" "jenkins_gcs_object_admin" {
  bucket = "static-backup-bucket"
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.jenkins.email}"

  depends_on = [google_service_account.jenkins]
}

resource "google_service_account_key" "jenkins_key" {
  service_account_id = google_service_account.jenkins.name
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
}

resource "google_secret_manager_secret" "jenkins_sa_key_secret" {
  secret_id = "jenkins-sa-key-${var.env}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "jenkins_sa_key_version" {
  secret      = google_secret_manager_secret.jenkins_sa_key_secret.id
  secret_data_wo = base64decode(google_service_account_key.jenkins_key.private_key)
}

# Jenkins 인스턴스
resource "google_compute_instance" "jenkins" {
  name         = var.jenkins_instance_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20250425"
      size  = 30
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
    network_ip = "10.30.10.2"
  }

  service_account {
    email  = google_service_account.jenkins.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata = {
    ssh-keys = join("\n", local.ssh_key_entries)
  }

  metadata_startup_script = local.rendered_startup_script

  tags = [local.jenkins_tag]

  depends_on = [google_service_account.jenkins]
}

# Jenkins 접근용 방화벽 규칙
resource "google_compute_firewall" "jenkins" {
  name    = "allow-jenkins"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["jenkins"]
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
}
  
resource "google_compute_firewall" "jenkins_to_monitoring" {
  name      = "jenkins-to-monitoring-${var.env}"
  network   = var.network
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["9100"]
  }

  source_tags = [var.mon_tag]
  target_tags = ["jenkins"]
}

resource "google_compute_firewall" "lb_to_jenkins" {
  name    = "allow-lb-to-jenkins"
  network = var.network

  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["9090"]
  }

  source_ranges = [
    "35.191.0.0/16",   
    "130.211.0.0/22"
  ]

  target_tags = ["jenkins"]
}

resource "google_compute_instance_group" "jenkins_group" {
  name      = "jenkins-group"
  zone      = var.zone
  instances = [google_compute_instance.jenkins.self_link]

  named_port {
    name = var.jenkins_service_name
    port = var.jenkins_port
  }
}

resource "google_compute_health_check" "health_check" {
  name = "jenkins-health-check"

  http_health_check {
    port         = var.jenkins_port
    request_path = var.health_check_path 
  }
}

resource "google_project_iam_member" "jenkins_tunnel_resource_Accessor" {
  project = var.project_id
  role    = "roles/iap.tunnelResourceAccessor"
  member  = "serviceAccount:${google_service_account.jenkins.email}"

  depends_on = [google_service_account.jenkins]
}