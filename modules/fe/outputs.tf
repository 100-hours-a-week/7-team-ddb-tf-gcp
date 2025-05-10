output "instance_self_link" {
  description = "fe instance의 self_link"
  value       = google_compute_instance.fe.self_link
}

output "instance_group" {
  description = "fe instance를 포함한 instance group의 self_link"
  value       = google_compute_instance_group.fe_group.self_link
}

output "health_check" {
  description = "fe instance group에 연결된 헬스체크 리소스의 ID"
  value       = google_compute_health_check.fe.id
}