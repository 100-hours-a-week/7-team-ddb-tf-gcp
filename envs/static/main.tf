terraform {
  required_version = "1.11.4"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.31.1"
    }
  }
  backend "gcs" {
    bucket = "dolpin-terraform-state-30m1t350"
    prefix = "static"
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project_id
  region      = var.region
}

module "tf_automation" {
  source             = "./modules/tf_automation"
  schedules          = var.tf_automation_schedules
  env                = var.env
  bucket_location    = var.bucket_location
  region           = var.region
  project_id         = var.project_id
  repo_url           = var.repo_url
  account_key_name   = var.account_key_name
  envs_parameter     = var.envs_parameter
  backup_bucket_name = var.backup_bucket_name
}

module "loki_backup_bucket" {
  source = "./modules/cloud_storage"
  env = var.env
  bucket_name = var.loki_backup_bucket_name
  bucket_location = "asia-northeast3"
}

module "thanos_backup_bucket" {
  source = "./modules/cloud_storage"
  env = var.env
  bucket_name = var.thanos_backup_bucket_name
  bucket_location = "asia-northeast3"
}
  
module "secret" {
  source = "./modules/secret"
  db_envs = var.db_envs
  db_username = var.db_usernames
}