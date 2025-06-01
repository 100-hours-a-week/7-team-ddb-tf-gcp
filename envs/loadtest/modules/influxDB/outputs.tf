output "influxDB_instance_ip" {
  value = google_compute_instance.influxdb.network_interface[0].access_config[0].nat_ip
}