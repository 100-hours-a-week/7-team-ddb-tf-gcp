
output "instance_self_link" {
  description = "ai instance의 self_link"
  value       = google_compute_instance.ai.self_link
}

output "instance_group" {
  description = "ai instance를 포함한 instance group의 self_link"
  value       = google_compute_instance_group.ai_group.self_link
}

output "health_check" {
  description = "ai instance group에 연결된 헬스체크 리소스의 ID"
  value       = google_compute_health_check.ai.self_link
}