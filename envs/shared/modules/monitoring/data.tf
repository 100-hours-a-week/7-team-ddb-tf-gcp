data "google_secret_manager_secret_version" "dev_db_password" {
  secret = "projects/${var.project_id}/secrets/cloudsql-dolpinuser-password-dev"
  version = "latest"
}

data "google_secret_manager_secret_version" "prod_db_password" {
  secret = "projects/${var.project_id}/secrets/cloudsql-dolpinuser-password-prod"
  version = "latest"
}