output "cloudsql_private_ip" {
  description = "Private IP address of the Cloud SQL PostgreSQL instance"
  value = [
    for ip in google_sql_database_instance.postgres.ip_address :
    ip.ip_address if ip.type == "PRIVATE"
  ][0]
}