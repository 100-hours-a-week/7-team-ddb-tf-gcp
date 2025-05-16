resource "google_sql_database_instance" "postgres" {
  name             = "db-${var.env}-${var.component}"
  database_version = "POSTGRES_15"

  settings {
    tier = var.tier
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_network_id
    }
    user_labels = {
      name      = "${var.env}-${var.component}-${var.resource_type}"
      env       = var.env
      component = var.component
      type      = var.resource_type
    }
  }

  deletion_protection = var.deletion_protection

  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]
}

resource "google_sql_database" "default" {
  name     = var.db_name
  instance = google_sql_database_instance.postgres.id
}

resource "google_sql_user" "default" {
  name        = var.db_user
  instance    = google_sql_database_instance.postgres.id
  password_wo = var.db_password
}

resource "google_storage_bucket_iam_member" "allow_sql_export" {
  bucket = var.backup_bucket_name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_sql_database_instance.postgres.service_account_email_address}"
}

resource "google_storage_bucket_iam_member" "allow_sql_import" {
  bucket = var.backup_bucket_name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_sql_database_instance.postgres.service_account_email_address}"
}

resource "google_compute_global_address" "private_ip_range" {
  name          = "cloudsql-peering-range-${var.env}-${var.component}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.prefix_length
  network       = var.vpc_self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.vpc_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}