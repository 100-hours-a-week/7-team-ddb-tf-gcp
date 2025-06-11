resource "google_sql_database_instance" "postgres" {
  name             = "db-${var.env}-${var.component}"
  database_version = "POSTGRES_15"

  settings {
    tier = var.tier
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name  = "nat 경로"
        value = var.nat_ip_address
      }
    }
    
    user_labels = {
      name      = "${var.env}-${var.component}-${var.resource_type}"
      env       = var.env
      component = var.component
      type      = var.resource_type
    }
  }

  deletion_protection = var.deletion_protection
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!@#%^&*()-_+[]{}<>?"
}

resource "google_secret_manager_secret" "cloudsql_password" {
  secret_id = "cloudsql-dolpinuser-password-${var.env}"

  replication {
    auto {}
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_secret_manager_secret_version" "cloudsql_password_version" {
  secret      = google_secret_manager_secret.cloudsql_password.id
  secret_data = random_password.db_password.result

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_sql_database" "default" {
  name     = var.db_name
  instance = google_sql_database_instance.postgres.id
}

resource "google_sql_user" "default" {
  name     = var.db_user
  instance = google_sql_database_instance.postgres.id
  password_wo = random_password.db_password.result
}