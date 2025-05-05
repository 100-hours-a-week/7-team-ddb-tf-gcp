# 이미지 저장용 GCS 버킷 생성
resource "google_storage_bucket" "image_bucket" {
  name          = var.bucket_name
  location      = var.location
  force_destroy = var.force_destroy

  uniform_bucket_level_access = true 

  cors { 
    origin          = var.cors_origins
    method          = ["GET", "HEAD"]
    response_header = ["Content-Type"]
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