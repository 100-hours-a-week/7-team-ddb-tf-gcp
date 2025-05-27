locals {
  mon_tag               = "mon"
  dockercompose_content = file("${path.module}/files/docker-compose.yml")
  prometheus_content    = file("${path.module}/files/prometheus.yml")
  loki_content          = file("${path.module}/files/loki.yml")

  rendered_startup_script = templatefile("${path.module}/scripts/startup.sh", {
    name                  = "monitoring"
    dockercompose_content = local.dockercompose_content
    prometheus_content    = local.prometheus_content
    loki_content          = local.loki_content
  })
  ssh_key_entries = [
    for user in var.ssh_users :
    "${user}:${var.public_key}"
  ]
}
