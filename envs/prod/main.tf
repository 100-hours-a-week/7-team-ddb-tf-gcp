terraform {
  required_version = "1.11.4"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.31.1"
    }
    
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project_id
  region      = var.region
}