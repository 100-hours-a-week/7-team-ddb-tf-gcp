# 이미지 저장용 GCS 버킷 생성
resource "google_storage_bucket" "image_bucket" {
  name          = "${var.bucket_name}-${var.env}"
  location      = var.location
  force_destroy = var.force_destroy

  uniform_bucket_level_access = true 

  cors { 
    origin          = var.cors_origins
    method          = ["GET", "HEAD", "PUT", "OPTIONS"]
    response_header = ["Content-Type", "Access-Control-Allow-Origin", "Access-Control-Allow-Headers"]
    max_age_seconds = 3600
  }

  labels = {
    name        = "${var.env}-image-storage-bucket" 
    environment = var.env                           
    component   = "backend"                         
    type        = "gcs"                             
    managed_by  = "terraform"                       
  }
}

# 백엔드 서비스 계정에 전체 권한 부여
resource "google_storage_bucket_iam_member" "backend_full_access" { 
  bucket = google_storage_bucket.image_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.backend_service_account_email}"
}

# GCS 버킷을 로드 밸런서에 연결하고 CDN 기능 사용
resource "google_compute_backend_bucket" "image_backend_bucket" { 
  name        = "${var.bucket_name}-cdn-backend-${var.env}" 
  bucket_name = google_storage_bucket.image_bucket.name
  enable_cdn  = true 
} 

# 이미지 공개 읽기 권한 설정
resource "google_storage_bucket_iam_member" "public_access" { 
  bucket = google_storage_bucket.image_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers" 
}