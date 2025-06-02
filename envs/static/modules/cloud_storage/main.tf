resource "google_storage_bucket" "bucket" {
  name     = var.bucket_name
  location = var.bucket_location

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  labels = {
    name        = "${var.env}-bucket"
    environment = var.env
    component   = "static"
    type        = "gcs"
    managed_by  = "terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}