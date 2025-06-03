data "google_secret_manager_secret_version" "db_password" {
  secret = "projects/${var.project_id}/secrets/cloudsql-dolpinuser-password-${var.env}"
  version = "latest"
}