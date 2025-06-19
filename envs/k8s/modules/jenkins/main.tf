# Jenkins startup script 구성
locals {
  jenkins_tag = "jenkins"

  jenkins_dockerfile_content = file("${path.module}/files/Dockerfile.jenkins")
  dockercompose_content      = file("${path.module}/files/docker-compose.yml")

  rendered_startup_script = templatefile("${path.module}/scripts/startup.sh", {
    name                     = "jenkins"
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

# Artifact Registry 쓰기 권한 부여
resource "google_project_iam_member" "jenkins_artifact_registry_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.jenkins.email}"

  depends_on = [google_service_account.jenkins]
}

# GCS 버킷에 objectAdmin 권한 부여
resource "google_storage_bucket_iam_member" "jenkins_gcs_object_admin" {
  bucket = "backup-dolpin-k8s"
  role   = "roles/storage.objectAdmin"
  
  member = "serviceAccount:${google_service_account.jenkins.email}"

  depends_on = [google_service_account.jenkins]
}

resource "google_project_iam_member" "jenkins_tunnel_resource_Accessor" {
  project = var.project_id
  role    = "roles/iap.tunnelResourceAccessor"
  member  = "serviceAccount:${google_service_account.jenkins.email}"

  depends_on = [google_service_account.jenkins]
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

  metadata_startup_script = local.rendered_startup_script

  tags = [local.jenkins_tag]

  depends_on = [google_service_account.jenkins]
}

resource "google_compute_firewall" "allow_ssh_iap" {
  name    = "allow-ssh-from-iap"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]  # IAP가 사용하는 IP 범위
  target_tags   = [local.jenkins_tag]
}