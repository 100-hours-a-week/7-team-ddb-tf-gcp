output "k6_instance_ip" {
  description = "퍼블릭 IP 주소 (k6 인스턴스)"
  value       = module.k6.k6_instance_ip
}

output "influxDB_instance_ip" {
  description = "퍼블릭 IP 주소 (influxDB 인스턴스)"
  value       = module.influxDB.influxDB_instance_ip
}