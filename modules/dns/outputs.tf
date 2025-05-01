output "ssl_certificate_id" {
  description = "SSL certificate의 id"
  value       = google_compute_managed_ssl_certificate.ssl_cert.id
}

output "ssl_certificate_self_link" {
  description = "SSL certificate의 self-link"
  value       = google_compute_managed_ssl_certificate.ssl_cert.self_link
}
