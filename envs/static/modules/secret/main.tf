resource "random_password" "db_password" {
  for_each          = var.db_envs
  length            = 16
  special           = true
  override_special  = "!@#%^&*()-_+[]{}<>?"
}

resource "google_secret_manager_secret" "cloudsql_password" {
  for_each  = var.db_envs
  secret_id = "cloudsql-dolpinuser-password-${each.key}"
  replication {
    auto {}
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_secret_manager_secret_version" "cloudsql_password_version" {
  for_each    = var.db_envs
  secret      = google_secret_manager_secret.cloudsql_password[each.key].id
  secret_data = random_password.db_password[each.key].result
  lifecycle {
    prevent_destroy = true
  }
}