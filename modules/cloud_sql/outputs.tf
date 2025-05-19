output "cloudsql_public_ip" {
  description = "cloud sql의 공개 ip 주소"
  value       = google_sql_database_instance.postgres.public_ip_address
}