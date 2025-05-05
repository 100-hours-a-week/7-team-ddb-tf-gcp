# LB용 Global IP
resource "google_compute_global_address" "lb_ip" {
  name = "lb-ip-${var.env}"
}

# 서비스별 DNS A 레코드 (each.value.domain 사용)
resource "google_dns_record_set" "lb_dns" {
  for_each     = var.services
  name         = "${each.value.domain}."
  type         = "A"
  ttl          = 300
  managed_zone = var.dns_managed_zone
  rrdatas      = [google_compute_global_address.lb_ip.address]
}

# Managed SSL Certificate (기본 도메인 + 와일드카드)
resource "google_compute_managed_ssl_certificate" "ssl_cert" {
  name = "lb-ssl-${var.env}"
  managed {
    domains = [for svc in values(var.services) : svc.domain]
  }
}

# Backend Services
resource "google_compute_backend_service" "svc" {
  for_each      = var.services
  name          = "${each.key}-backend-${var.env}"
  protocol      = "HTTP"
  port_name     = each.value.port_name
  health_checks = [each.value.health_check]

  backend {
    group = each.value.instance_group
  }

  timeout_sec = 10
}

# HTTPS용 URL Map (호스트 기반 매칭 + default_service)
resource "google_compute_url_map" "https_map" {
  name = "https-map-${var.env}"

  dynamic "host_rule" {
    for_each = var.services
    content {
      hosts        = [each.value.domain]
      path_matcher = "${each.key}-matcher"
    }
  }

  dynamic "path_matcher" {
    for_each = var.services
    content {
      name            = "${each.key}-matcher"
      default_service = google_compute_backend_service.svc[each.key].self_link
    }
  }

  # 매칭 실패 시 첫 번째 서비스의 백엔드로
  default_service = google_compute_backend_service.svc[keys(var.services)[0]].self_link
}

# HTTPS Proxy & Forwarding (443)
resource "google_compute_target_https_proxy" "https" {
  name             = "https-proxy-${var.env}"
  url_map          = google_compute_url_map.https_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_cert.id]
}

resource "google_compute_global_forwarding_rule" "https" {
  name                  = "https-fw-${var.env}"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.lb_ip.address
  port_range            = "443"
  target                = google_compute_target_https_proxy.https.self_link
}

# HTTP → HTTPS 리다이렉트
resource "google_compute_url_map" "redirect_map" {
  name = "redirect-map-${var.env}"
  default_url_redirect {
    https_redirect         = true
    strip_query            = false
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
  }
}

resource "google_compute_target_http_proxy" "redirect" {
  name    = "redirect-proxy-${var.env}"
  url_map = google_compute_url_map.redirect_map.self_link
}

resource "google_compute_global_forwarding_rule" "redirect" {
  name                  = "redirect-fw-${var.env}"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.lb_ip.address
  port_range            = "80"
  target                = google_compute_target_http_proxy.redirect.self_link
}

# Firewall: GCP HTTP(S) 프록시 → 서비스 인스턴스 (80/443)
resource "google_compute_firewall" "lb_to_instances" {
  name      = "lb-to-instances-${var.env}"
  network   = var.network
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22",
  ]
  # 각 서비스 모듈이 인스턴스에 붙인 태그(서비스 키)
  target_tags = [for svc in keys(var.services) : svc]
}

