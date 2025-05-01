resource "google_compute_managed_ssl_certificate" "ssl_cert" {
  name = var.name

  managed {
    domains = var.domains
  }
}
