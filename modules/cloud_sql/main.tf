resource "google_sql_database_instance" "postgres" {
  name             = "db-${var.env}-${var.component}"
  database_version = "POSTGRES_15"

  settings {
    tier = var.tier
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_network_id
    }
  }

  deletion_protection = var.deletion_protection
}