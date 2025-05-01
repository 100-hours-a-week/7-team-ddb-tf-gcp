output "cloudsql_private_ip" {
  description = "Private IP address of the Cloud SQL PostgreSQL instance"
  value       = google_sql_database_instance.postgres.private_ip_address
}