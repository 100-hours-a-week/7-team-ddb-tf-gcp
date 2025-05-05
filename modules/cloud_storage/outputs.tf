output "cdn_backend_bucket_self_link" {
  description = "CDN 대상이 되는 Backend Bucket의 self_link"
  value       = google_compute_backend_bucket.image_backend_bucket.self_link
}